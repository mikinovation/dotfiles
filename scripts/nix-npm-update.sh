#!/bin/sh

# Refresh the npm packages vendored under nix/pkgs/ to their latest published
# versions. Mirrors the manual procedure documented in
# nix/programs/claude-code/skills/nix-npm-update/SKILL.md (types B, C and D).
# Type A (secretlint in the root package.json) is left to renovate.
#
# Requires: git, node, npm, jq, curl, nix.
# Writes a "<pkg>: <old> -> <new>" report to stdout, and to $SUMMARY_FILE when set.

set -eu

REPO_ROOT="$(git rev-parse --show-toplevel)"
PKGS_DIR="$REPO_ROOT/nix/pkgs"
SUMMARY_FILE="${SUMMARY_FILE:-}"

report() {
  echo "$1"
  if [ -n "$SUMMARY_FILE" ]; then
    echo "$1" >> "$SUMMARY_FILE"
  fi
}

# Current `version = "x.y.z";` attribute of a nix/pkgs/*.nix file.
current_version() {
  awk '$1 == "version" && $2 == "=" { gsub(/[";]/, "", $3); print $3; exit }' "$1"
}

# npm view for a package, printing "version<TAB>tarball<TAB>integrity" with the
# "sha512-" prefix stripped (fetchurl's sha512 attribute takes bare base64).
# Fails (non-zero) when the package or version does not exist.
# npm flattens multi-field --json output into "dist.tarball" style keys; older
# npm nests them, so accept both.
npm_dist() {
  view_out="$(npm view "$1" version dist.tarball dist.integrity --json 2> /dev/null)" || return 1
  [ -n "$view_out" ] || return 1
  echo "$view_out" | jq -er '
    [.version, (."dist.tarball" // .dist.tarball), (."dist.integrity" // .dist.integrity)]
    | if any(.[]; . == null) then error("unexpected npm view output") else . end
    | .[2] |= sub("^sha512-"; "")
    | @tsv
  '
}

# Rewrite the string literal of `<attr> = "...";` lines. Base64 hashes and
# registry URLs never contain "&", so awk's sub() replacement is safe here.
set_attr() {
  file="$1"
  attr="$2"
  value="$3"
  awk -v attr="$attr" -v value="$value" '
    $1 == attr && $2 == "=" { sub(/"[^"]*"/, "\"" value "\"") }
    { print }
  ' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
}

# Rewrite url/sha512 inside the `<label> = fetchurl { ... }` block only.
set_fetchurl() {
  file="$1"
  label="$2"
  url="$3"
  sha="$4"
  awk -v label="$label" -v url="$url" -v sha="$sha" '
    $2 == "=" && $3 == "fetchurl" { block = $1 }
    block == label && $1 == "url" { sub(/"[^"]*"/, "\"" url "\"") }
    block == label && $1 == "sha512" { sub(/"[^"]*"/, "\"" sha "\"") }
    { print }
  ' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
}

set_npm_deps_hash() {
  hash="$(nix run nixpkgs#prefetch-npm-deps -- "$2")"
  set_attr "$1" "npmDepsHash" "$hash"
}

# npm refuses to run when packageManager names a different manager (difit ships
# `packageManager: pnpm`). The field is not recorded in the lockfile, so dropping
# it here does not change the generated lock.
strip_package_manager() {
  node -e '
    const fs = require("fs");
    const path = process.argv[1] + "/package.json";
    const p = JSON.parse(fs.readFileSync(path, "utf8"));
    delete p.packageManager;
    fs.writeFileSync(path, JSON.stringify(p, null, 2) + "\n");
  ' "$1"
}

# The published package.json must be massaged exactly like the `src` derivation
# in the matching .nix does, otherwise `npm ci` fails on a lockfile mismatch.
prepare_package_json() {
  case "$1" in
    vue-language-server)
      node -e '
        const fs = require("fs");
        const path = process.argv[1] + "/package.json";
        const p = JSON.parse(fs.readFileSync(path, "utf8"));
        delete p.devDependencies;
        p.dependencies = Object.assign({}, p.dependencies, { typescript: "^5.9.3" });
        fs.writeFileSync(path, JSON.stringify(p, null, 2) + "\n");
      ' "$2"
      ;;
    difit)
      node -e '
        const fs = require("fs");
        const path = process.argv[1] + "/package.json";
        const p = JSON.parse(fs.readFileSync(path, "utf8"));
        delete p.devDependencies;
        fs.writeFileSync(path, JSON.stringify(p, null, 2) + "\n");
      ' "$2"
      ;;
    vue-typescript-plugin)
      # Packaged as published; no massaging.
      ;;
    *)
      echo "prepare_package_json: unknown package $1" >&2
      exit 1
      ;;
  esac
}

# Type B: buildNpmPackage with a regenerated lockfile.
update_build_npm_package() {
  pkg="$1"
  npm_pkg="$2"
  nix_file="$PKGS_DIR/$pkg.nix"
  lock_file="$PKGS_DIR/$pkg-lock.json"

  old_version="$(current_version "$nix_file")"
  if ! dist="$(npm_dist "$npm_pkg")"; then
    report "$pkg: skip (npm view failed)"
    return 0
  fi
  new_version="$(echo "$dist" | cut -f1)"
  tgz_url="$(echo "$dist" | cut -f2)"
  sha512="$(echo "$dist" | cut -f3)"

  if [ "$old_version" = "$new_version" ]; then
    report "$pkg: skip ($old_version)"
    return 0
  fi

  work="$(mktemp -d)"
  mkdir -p "$work/src"
  curl -sSL "$tgz_url" | tar xz -C "$work/src" --strip-components=1
  prepare_package_json "$pkg" "$work/src"
  strip_package_manager "$work/src"
  rm -f "$work/src/package-lock.json"
  (cd "$work/src" && npm install --package-lock-only --ignore-scripts > /dev/null)
  cp "$work/src/package-lock.json" "$lock_file"
  rm -rf "$work"

  set_attr "$nix_file" "version" "$new_version"
  set_fetchurl "$nix_file" "tgz" "$tgz_url" "$sha512"
  set_npm_deps_hash "$nix_file" "$lock_file"

  report "$pkg: $old_version -> $new_version"
}

# Type C: claude-code ships a JS package plus a platform-specific binary.
update_claude_code() {
  nix_file="$PKGS_DIR/claude-code.nix"
  old_version="$(current_version "$nix_file")"

  if ! main_dist="$(npm_dist "@anthropic-ai/claude-code")"; then
    report "claude-code: skip (npm view failed)"
    return 0
  fi
  new_version="$(echo "$main_dist" | cut -f1)"

  if [ "$old_version" = "$new_version" ]; then
    report "claude-code: skip ($old_version)"
    return 0
  fi

  # The native package is published separately and can lag behind the main one.
  if ! native_dist="$(npm_dist "@anthropic-ai/claude-code-linux-x64@$new_version")"; then
    report "claude-code: skip ($new_version linux-x64 not published yet)"
    return 0
  fi

  set_attr "$nix_file" "version" "$new_version"
  set_fetchurl "$nix_file" "mainTgz" \
    "$(echo "$main_dist" | cut -f2)" "$(echo "$main_dist" | cut -f3)"
  set_fetchurl "$nix_file" "nativeTgz" \
    "$(echo "$native_dist" | cut -f2)" "$(echo "$native_dist" | cut -f3)"

  report "claude-code: $old_version -> $new_version"
}

# Type D: prebuilt bundle with a dependency-free lockfile.
update_chrome_devtools_mcp() {
  nix_file="$PKGS_DIR/chrome-devtools-mcp.nix"
  lock_file="$PKGS_DIR/chrome-devtools-mcp-lock.json"

  old_version="$(current_version "$nix_file")"
  if ! dist="$(npm_dist "chrome-devtools-mcp")"; then
    report "chrome-devtools-mcp: skip (npm view failed)"
    return 0
  fi
  new_version="$(echo "$dist" | cut -f1)"

  if [ "$old_version" = "$new_version" ]; then
    report "chrome-devtools-mcp: skip ($old_version)"
    return 0
  fi

  # Only the version fields move; the lockfile stays dependency-free.
  node -e '
    const fs = require("fs");
    const [path, version] = process.argv.slice(1);
    const lock = JSON.parse(fs.readFileSync(path, "utf8"));
    lock.version = version;
    lock.packages[""].version = version;
    fs.writeFileSync(path, JSON.stringify(lock, null, 2) + "\n");
  ' "$lock_file" "$new_version"

  set_attr "$nix_file" "version" "$new_version"
  set_fetchurl "$nix_file" "tgz" \
    "$(echo "$dist" | cut -f2)" "$(echo "$dist" | cut -f3)"
  # npmDepsHash stays as is: the lockfile has no dependencies to fetch, and
  # prefetch-npm-deps refuses to hash an empty lockfile (the .nix opts out with
  # forceEmptyCache instead).

  report "chrome-devtools-mcp: $old_version -> $new_version"
}

main() {
  update_build_npm_package vue-language-server @vue/language-server
  update_build_npm_package vue-typescript-plugin @vue/typescript-plugin
  update_build_npm_package difit difit
  update_claude_code
  update_chrome_devtools_mcp
}

main

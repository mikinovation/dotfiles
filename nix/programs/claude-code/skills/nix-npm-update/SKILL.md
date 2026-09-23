---
name: nix-npm-update
description: nix管理下のnpm依存を最新化するスキル。package.jsonの通常依存、buildNpmPackage形式のラッパーパッケージ（vue-language-server, vue-typescript-plugin, difit）、tgz直接展開形式（claude-code）、プリビルドバンドル形式（chrome-devtools-mcp）、GitHubソース形式（tanteki）の5種を扱う。「npmを最新化」「nixのnpm更新」「secretlintを上げて」「claude-code更新」「vue-language-server更新」「difit更新」「chrome-devtools-mcp更新」「tanteki更新」などで使用。
---

# nix-npm-update: nix管理下のnpm依存更新スキル

このリポジトリにはnpm依存が5種類の形で存在する。常に全種別を対象として、差分があるものだけ更新する。

## 対象の分類

| パッケージ | 種別 | 定義ファイル |
|------|------|------|
| secretlint | A | `/package.json`, `/package-lock.json` |
| vue-language-server | B | `nix/pkgs/vue-language-server.nix` |
| vue-typescript-plugin | B | `nix/pkgs/vue-typescript-plugin.nix` |
| difit | B | `nix/pkgs/difit.nix` |
| claude-code | C | `nix/pkgs/claude-code.nix` |
| chrome-devtools-mcp | D | `nix/pkgs/chrome-devtools-mcp.nix` |
| tanteki | E | `nix/pkgs/tanteki.nix` |

| 種別 | 形式 |
|------|------|
| A. 通常npm | renovateで自動更新済。手動なら `npm update` |
| B. buildNpmPackage | tgz fetchUrl + 手書きlock + npmDepsHash |
| C. tgz直接展開 | mainTgz + nativeTgz (linux-x64) 2本立て |
| D. プリビルドバンドル | tgz fetchUrl + 空lock + forceEmptyCache + 手書きinstallPhase |
| E. GitHubソース | fetchFromGitHub + 上流同梱lock + npmDepsHash |

npm package名は nix のパッケージ名と一致しないものがある。

| nix のパッケージ名 | npm package名 |
|------|------|
| vue-language-server | `@vue/language-server` |
| vue-typescript-plugin | `@vue/typescript-plugin` |
| difit | `difit`（scope なし） |
| claude-code (main) | `@anthropic-ai/claude-code` |
| claude-code (native) | `@anthropic-ai/claude-code-linux-x64` |

## 手順

### 1. 現行と最新を確認する

差分が無いものはスキップ。

現行版:
- secretlint: `npm pkg get devDependencies.secretlint`
- vue-language-server: `nix/pkgs/vue-language-server.nix` の `version` 属性
- vue-typescript-plugin: `nix/pkgs/vue-typescript-plugin.nix` の `version` 属性
- difit: `nix/pkgs/difit.nix` の `version` 属性
- claude-code: `nix/pkgs/claude-code.nix` の `version` 属性
- chrome-devtools-mcp: `nix/pkgs/chrome-devtools-mcp.nix` の `version` 属性
- tanteki: `nix/pkgs/tanteki.nix` の `src.rev`（npmレジストリではなくGitHubの最新コミットと比較する）

最新版を並列で取得する。種別Aは version だけでよい。種別B/C は手順3/4 で tgz情報も使うため、最初からまとめて取る。種別D/E は取得方法が異なるので、それぞれ手順5/6 で取得する。

```bash
npm view secretlint version & \
npm view @vue/language-server version dist.tarball dist.integrity --json > /tmp/vls.json & \
npm view @vue/typescript-plugin version dist.tarball dist.integrity --json > /tmp/vtp.json & \
npm view difit version dist.tarball dist.integrity --json > /tmp/difit.json & \
npm view @anthropic-ai/claude-code version dist.tarball dist.integrity --json > /tmp/cc-main.json & \
wait
```

### 2. 種別A (secretlint) の更新

renovateが自動更新するため、手動更新はrenovateと競合する可能性がある。実行前に open PR を `gh pr list --search "secretlint"` で確認する。renovate が止まっている等の正当理由がなければスキップ。`package.json` は固定バージョン記法なので `--save-exact` を維持する。

```bash
npm install --save-exact secretlint@latest @secretlint/secretlint-rule-preset-recommend@latest
```

### 3. 種別B (buildNpmPackage) の更新

`PKG` と `NPM_PKG` を切り替えて vue-language-server / vue-typescript-plugin / difit の各々に同手順を適用する。difit は scope なしなので `NPM_PKG=difit` となる。

#### 3.1. 手順1のJSONから値を取り出す

```bash
PKG=vue-language-server                  # または vue-typescript-plugin / difit
NPM_PKG=@vue/language-server             # または @vue/typescript-plugin / difit
JSON=/tmp/vls.json                       # または /tmp/vtp.json / /tmp/difit.json
NEW_VER=$(jq -r '.version' "$JSON")
TGZ_URL=$(jq -r '.dist.tarball' "$JSON")
SHA512=$(jq -r '.dist.integrity' "$JSON")
```

`SHA512` は `sha512-...=` 形式でそのまま `.nix` に貼れる。

#### 3.2. package-lock.json を再生成

`nix/pkgs/${PKG}-lock.json` を新バージョンで作り直す。`dontNpmBuild = true;` のため `--ignore-scripts` 必須。

```bash
REPO_ROOT="$(git rev-parse --show-toplevel)"
WORK=$(mktemp -d)
mkdir -p "$WORK/src"
curl -sL "$TGZ_URL" | tar xz -C "$WORK/src" --strip-components=1
( cd "$WORK/src" && rm -f package-lock.json && npm install --package-lock-only --ignore-scripts )
cp "$WORK/src/package-lock.json" "$REPO_ROOT/nix/pkgs/${PKG}-lock.json"
```

lockファイルは手書きで再生成するため、上流の `package-lock.json` 仕様変更に追随する必要がある。生成後に `lockfileVersion` を確認する。

#### 3.3. .nix の version/url/sha512 を更新

`nix/pkgs/${PKG}.nix` の `version` / `url` / `sha512` を 3.1 の値に書き換える。`npmDepsHash` は次手順で更新する。

#### 3.4. npmDepsHash を更新

`prefetch-npm-deps` で lockfile から直接計算する（フルビルド不要）:

```bash
nix run nixpkgs#prefetch-npm-deps -- ./nix/pkgs/${PKG}-lock.json
```

出力された `sha256-...=` を `.nix` の `npmDepsHash` に貼る。

### 4. 種別C (claude-code) の更新

main は手順1で取得済 (`/tmp/cc-main.json`)。native はバージョン依存なので、main の version 確定後に取得する。

```bash
NEW_VER=$(jq -r '.version' /tmp/cc-main.json)
MAIN_URL=$(jq -r '.dist.tarball' /tmp/cc-main.json)
MAIN_SHA=$(jq -r '.dist.integrity' /tmp/cc-main.json)
eval "$(npm view "@anthropic-ai/claude-code-linux-x64@$NEW_VER" dist.tarball dist.integrity --json \
  | jq -r '"NATIVE_URL=\(.dist.tarball)\nNATIVE_SHA=\(.dist.integrity)"')"
```

`nix/pkgs/claude-code.nix` の `version`, `mainTgz.{url,sha512}`, `nativeTgz.{url,sha512}` を書き換える。

native パッケージは新バージョンで未公開のことがある。`@anthropic-ai/claude-code-linux-x64@$NEW_VER` の `npm view` がエラーになったら、更新を中止してユーザーに報告する。

### 5. 種別D (chrome-devtools-mcp) の更新

chrome-devtools-mcp の配布tgzは `build/` にビルド済みバンドルを同梱し、`dependencies` が空（依存はthird_partyとして内包）。一方 `devDependencies` (eslint等) は残るため、種別Bの手順をそのまま使うと `npm ci` が devDeps を取りに行って失敗する。専用手順が必要。

#### 5.1. 最新版とtgz情報を取得

```bash
npm view chrome-devtools-mcp version dist.tarball dist.integrity --json > /tmp/cdm.json
NEW_VER=$(jq -r '.version' /tmp/cdm.json)
TGZ_URL=$(jq -r '.dist.tarball' /tmp/cdm.json)
SHA512=$(jq -r '.dist.integrity' /tmp/cdm.json)
```

#### 5.2. lockファイルは空のまま据え置き

`nix/pkgs/chrome-devtools-mcp-lock.json` は依存ゼロの固定lock。`version` フィールドだけ新バージョンに合わせる（`packages[""].version` と top-level `version`）。bin/engines が上流で変わっていないかは package.json で確認する。

#### 5.3. .nix の version/url/sha512 を更新

`nix/pkgs/chrome-devtools-mcp.nix` の `version` / `url` / `sha512` を 5.1 の値に書き換える。

注意点（種別Bとの差分。上流仕様が変わらない限り据え置きでよい）:
- `forceEmptyCache = true;` — 依存ゼロのため空キャッシュを明示的に許可する。
- src の runCommand 内で、package.json の `devDependencies` / `dependencies` / `scripts` を node で削除する。空lockと整合させるため。
- `installPhase` を手書きしている。デフォルトの npmInstallHook は node_modules 前提で失敗するため、`build/` をコピーして `makeWrapper` で bin を node ラップする。bin のパス（`build/src/bin/chrome-devtools-mcp.js`）が上流で変わっていないか package.json の `bin` で確認する。

#### 5.4. npmDepsHash を更新

空lockに対する `prefetch-npm-deps` の出力を貼る（依存が無くても固定値が出る）:

```bash
nix run nixpkgs#prefetch-npm-deps -- ./nix/pkgs/chrome-devtools-mcp-lock.json
```

### 6. 種別E (tanteki) の更新

tanteki はnpmレジストリではなくGitHubリポジトリを直接取得する。`package-lock.json` は上流の `skills/tanteki` に同梱されているため再生成しない。`src.rev`、`src.hash`、`npmDepsHash` は常に同時に更新する。

#### 6.1. 最新コミットを取得

```bash
NEW_REV=$(gh api repos/iwasa-kosui/tanteki/commits/main --jq '.sha')
NEW_DATE=$(gh api repos/iwasa-kosui/tanteki/commits/main --jq '.commit.committer.date' | cut -dT -f1)
```

現行の `src.rev` と同じならスキップする。

#### 6.2. ソースhashを取得

`nix flake prefetch` の出力hashは `fetchFromGitHub` の `hash` にそのまま使える。

```bash
SRC=$(nix flake prefetch --json "github:iwasa-kosui/tanteki/$NEW_REV")
echo "$SRC" | jq -r '.hash'
STORE=$(echo "$SRC" | jq -r '.storePath')
```

`nix/pkgs/tanteki.nix` の `version`（`0-unstable-$NEW_DATE`）、`src.rev`、`src.hash` を書き換える。

#### 6.3. npmDepsHash を更新

上流同梱のlockから直接計算する。

```bash
nix run nixpkgs#prefetch-npm-deps -- "$STORE/skills/tanteki/package-lock.json"
```

#### 6.4. postPatch の追随

`postPatch` は `substituteInPlace --replace-fail` で上流の文面を書き換えている。対象は `SKILL.md` と `references/lint.md` の `npm ci` 指示、コマンド例の先頭の `node `、`scripts/lint.mjs` の shebang である。上流で該当文が変わるとビルドが `--replace-fail` で失敗する。その場合は新しい文面に合わせて置換元の文字列を直す。

#### 6.5. 動作確認

ビルド後、store上（read-only）でlintが動くことを確認する。

```bash
TANTEKI=$(nix build --no-link --print-out-paths --impure \
  --expr 'with import <nixpkgs> { }; callPackage ./nix/pkgs/tanteki.nix { }')
"$TANTEKI/scripts/lint.mjs" --type design-doc <適当なMarkdownの絶対パス>
```

`scripts/lint.mjs` は `import.meta.url` と `process.argv[1]` を比較して起動する。symlink 経由で呼ぶと両者が一致せず、検査せずに終了コード0を返す。`~/.claude/skills/tanteki/` 配下ではなく、`readlink -f` で解決した store のパスで実行する。

### 7. ビルド検証

種別B/C/E を更新した場合は home-manager のビルドで npmDepsHash / tgz hash / ソースhash を実評価する:

```bash
nix build --no-link ./nix#checks.x86_64-linux.home-manager-build
```

### 8. Post-Task Verification と報告

CLAUDE.md (project) の Post-Task Verification を実行する。

```bash
nix run ./nix#lint && nix run ./nix#fmt && nix run ./nix#test
```

報告フォーマット（差分なしでスキップしたものも明記。コミット・プッシュは明示指示があるまでしない）:

```
更新対象:
  - <pkg名>: <old> -> <new>
  - <pkg名>: skip (no diff)
変更ファイル:
  - <path>
  - ...
ビルド: ok / fail
lint/fmt/test: ok / fail
```

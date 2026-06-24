---
name: nix-npm-update
description: nix管理下のnpm依存を最新化するスキル。package.jsonの通常依存、buildNpmPackage形式のラッパーパッケージ（vue-language-server, vue-typescript-plugin, difit）、tgz直接展開形式（claude-code）、プリビルドバンドル形式（chrome-devtools-mcp）の4種を扱う。「npmを最新化」「nixのnpm更新」「secretlintを上げて」「claude-code更新」「vue-language-server更新」「difit更新」「chrome-devtools-mcp更新」などで使用。
---

# nix-npm-update: nix管理下のnpm依存更新スキル

このリポジトリにはnpm依存が4種類の形で存在する。常に全種別を対象として、差分があるものだけ更新する。

## 対象の分類

| 種別 | 場所 | 形式 |
|------|------|------|
| A. 通常npm | `/package.json`, `/package-lock.json` | renovateで自動更新済。手動なら `npm update` |
| B. buildNpmPackage | `nix/pkgs/vue-language-server.nix`, `nix/pkgs/vue-typescript-plugin.nix`, `nix/pkgs/difit.nix` | tgz fetchUrl + 手書きlock + npmDepsHash |
| C. tgz直接展開 | `nix/pkgs/claude-code.nix` | mainTgz + nativeTgz (linux-x64) 2本立て |
| D. プリビルドバンドル | `nix/pkgs/chrome-devtools-mcp.nix` | tgz fetchUrl + 空lock + forceEmptyCache + 手書きinstallPhase |

対象パッケージ:
- secretlint (種別A)
- vue-language-server (種別B)
- vue-typescript-plugin (種別B)
- difit (種別B)
- claude-code (種別C)
- chrome-devtools-mcp (種別D)

## 手順

### 1. 現行と最新を確認する

差分が無いものはスキップ。

現行版:
- secretlint: `npm pkg get devDependencies.secretlint`
- vue-language-server: `nix/pkgs/vue-language-server.nix` の `version` 属性
- vue-typescript-plugin: `nix/pkgs/vue-typescript-plugin.nix` の `version` 属性
- difit: `nix/pkgs/difit.nix` の `version` 属性
- claude-code: `nix/pkgs/claude-code.nix` の `version` 属性

最新版を並列で取得（種別Aだけ version のみ、種別B/C は手順3/4 で tgz情報も使うので最初からまとめて取る）:

```bash
npm view secretlint version & \
npm view @vue/language-server version dist.tarball dist.integrity --json > /tmp/vls.json & \
npm view @vue/typescript-plugin version dist.tarball dist.integrity --json > /tmp/vtp.json & \
npm view difit version dist.tarball dist.integrity --json > /tmp/difit.json & \
npm view @anthropic-ai/claude-code version dist.tarball dist.integrity --json > /tmp/cc-main.json & \
wait
```

npm package名対応:
- vue-language-server → `@vue/language-server`
- vue-typescript-plugin → `@vue/typescript-plugin`
- difit → `difit` (scope なし)
- claude-code (main) → `@anthropic-ai/claude-code`
- claude-code (native) → `@anthropic-ai/claude-code-linux-x64`

### 2. 種別A (secretlint) の更新

renovateで自動更新されるため、手動更新の前に open PR を `gh pr list --search "secretlint"` で確認する。renovate が止まっている等の正当理由がなければスキップ。`package.json` は固定バージョン記法なので `--save-exact` を維持する。

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

native パッケージが新バージョンで未公開のケースがあるため、`@anthropic-ai/claude-code-linux-x64@$NEW_VER` の `npm view` がエラーになる場合は更新を中止し、ユーザーに報告する。

### 4b. 種別D (chrome-devtools-mcp) の更新

chrome-devtools-mcp の配布tgzは `build/` にビルド済みバンドルを同梱し、`dependencies` が空（依存はthird_partyとして内包）。一方 `devDependencies` (eslint等) は残るため、種別Bの手順をそのまま使うと `npm ci` が devDeps を取りに行って失敗する。専用手順が必要。

#### 4b.1. 最新版とtgz情報を取得

```bash
npm view chrome-devtools-mcp version dist.tarball dist.integrity --json > /tmp/cdm.json
NEW_VER=$(jq -r '.version' /tmp/cdm.json)
TGZ_URL=$(jq -r '.dist.tarball' /tmp/cdm.json)
SHA512=$(jq -r '.dist.integrity' /tmp/cdm.json)
```

#### 4b.2. lockファイルは空のまま据え置き

`nix/pkgs/chrome-devtools-mcp-lock.json` は依存ゼロの固定lock。`version` フィールドだけ新バージョンに合わせる（`packages[""].version` と top-level `version`）。bin/engines が上流で変わっていないかは package.json で確認する。

#### 4b.3. .nix の version/url/sha512 を更新

`nix/pkgs/chrome-devtools-mcp.nix` の `version` / `url` / `sha512` を 4b.1 の値に書き換える。

注意点（種別Bとの差分。上流仕様が変わらない限り据え置きでよい）:
- `forceEmptyCache = true;` — 依存ゼロのため空キャッシュを明示的に許可する。
- src の runCommand 内で package.json から `devDependencies` / `dependencies` / `scripts` を node で削除し、空lockと整合させる。
- `installPhase` を手書きしている。デフォルトの npmInstallHook は node_modules 前提で失敗するため、`build/` をコピーして `makeWrapper` で bin を node ラップする。bin のパス（`build/src/bin/chrome-devtools-mcp.js`）が上流で変わっていないか package.json の `bin` で確認する。

#### 4b.4. npmDepsHash を更新

空lockに対する `prefetch-npm-deps` の出力を貼る（依存が無くても固定値が出る）:

```bash
nix run nixpkgs#prefetch-npm-deps -- ./nix/pkgs/chrome-devtools-mcp-lock.json
```

### 5. ビルド検証

種別B/C を更新した場合は home-manager のビルドで npmDepsHash / tgz hash を実評価する:

```bash
nix build --no-link ./nix#checks.x86_64-linux.home-manager-build
```

### 6. Post-Task Verification と報告

CLAUDE.md (project) の Post-Task Verification (`nix run ./nix#lint && nix run ./nix#fmt && nix run ./nix#test`) を実行する。

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

## 注意

- renovateが種別Aを自動更新しているため、種別Aの手動更新はrenovateと競合する可能性がある。実行前に open PR を `gh pr list --search "secretlint"` で確認する。
- 種別Bのlockファイルは手書き再生成のため、上流の `package-lock.json` 仕様変更（lockfileVersion）に追随する必要があるケースがある。生成後にlockfileVersionを確認する。

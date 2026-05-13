---
name: nix-npm-update
description: nix管理下のnpm依存を最新化するスキル。package.jsonの通常依存、buildNpmPackage形式のラッパーパッケージ（vue-language-server, vue-typescript-plugin）、tgz直接展開形式（claude-code）の3種を扱う。「npmを最新化」「nixのnpm更新」「secretlintを上げて」「claude-code更新」「vue-language-server更新」などで使用。
---

# nix-npm-update: nix管理下のnpm依存更新スキル

このリポジトリにはnpm依存が3種類の形で存在する。常に全種別を対象として、差分があるものだけ更新する。

## 対象の分類

| 種別 | 場所 | 形式 |
|------|------|------|
| A. 通常npm | `/package.json`, `/package-lock.json` | renovateで自動更新済。手動なら `npm update` |
| B. buildNpmPackage | `nix/pkgs/vue-language-server.nix`, `nix/pkgs/vue-typescript-plugin.nix` | tgz fetchUrl + 手書きlock + npmDepsHash |
| C. tgz直接展開 | `nix/pkgs/claude-code.nix` | mainTgz + nativeTgz (linux-x64) 2本立て |

対象パッケージ:
- secretlint (種別A)
- vue-language-server (種別B)
- vue-typescript-plugin (種別B)
- claude-code (種別C)

## 手順

### 1. 現行バージョンと最新バージョンを確認する

差分があるパッケージだけを以降の手順で更新する。差分が無いものはスキップ。

現行版:
- secretlint: `npm pkg get devDependencies.secretlint`
- vue-language-server: `nix/pkgs/vue-language-server.nix` の `version` 属性
- vue-typescript-plugin: `nix/pkgs/vue-typescript-plugin.nix` の `version` 属性
- claude-code: `nix/pkgs/claude-code.nix` の `version` 属性

最新版（4つを並列で取得）:
```bash
npm view secretlint version & \
npm view @vue/language-server version & \
npm view @vue/typescript-plugin version & \
npm view @anthropic-ai/claude-code version & \
wait
```

npm package名対応:
- vue-language-server → `@vue/language-server`
- vue-typescript-plugin → `@vue/typescript-plugin`
- claude-code (main) → `@anthropic-ai/claude-code`
- claude-code (native) → `@anthropic-ai/claude-code-linux-x64`

### 2. 種別Aの更新手順 (secretlint)

renovateで通常は自動化されているため、手動更新する正当な理由（renovateが止まっている、急ぎ等）を確認する。現在の `package.json` は固定バージョン (`"13.0.0"` の形式) なので `--save-exact` を維持する。

```bash
npm install --save-exact secretlint@latest @secretlint/secretlint-rule-preset-recommend@latest
```

検証は `Post-Task Verification` 節（後述）で実施する。

### 3. 種別Bの更新手順 (buildNpmPackage)

#### 3.1. 新tgzのURL/sha512を取得

```bash
NPM_PKG="@vue/language-server"     # または @vue/typescript-plugin
eval "$(npm view "$NPM_PKG@latest" version dist.tarball dist.integrity --json \
  | jq -r '"NEW_VER=\(.version)\nTGZ_URL=\(.dist.tarball)\nSHA512=\(.dist.integrity)"')"
echo "version=$NEW_VER url=$TGZ_URL sha512=$SHA512"
```

`SHA512` は `sha512-...=` 形式でそのまま `.nix` に貼れる。

#### 3.2. package-lock.json を再生成

リポジトリ内の `nix/pkgs/<pkg>-lock.json` を新バージョンで作り直す。`REPO_ROOT` はリポジトリ絶対パス。

```bash
REPO_ROOT="$(git rev-parse --show-toplevel)"
WORK=$(mktemp -d)
mkdir -p "$WORK/src"
curl -sL "$TGZ_URL" | tar xz -C "$WORK/src" --strip-components=1
( cd "$WORK/src" && rm -f package-lock.json && npm install --package-lock-only --ignore-scripts )
cp "$WORK/src/package-lock.json" "$REPO_ROOT/nix/pkgs/<pkg>-lock.json"
```

`<pkg>` は `vue-language-server` か `vue-typescript-plugin`。`dontNpmBuild = true;` のため `--ignore-scripts` は必須（scriptsを実行せずinstallのみ）。

#### 3.3. .nix の version/url/sha512 を更新

`nix/pkgs/<pkg>.nix` の `version` / `url` / `sha512` を上で取得した値に書き換える。`npmDepsHash` は次の手順で更新するため一旦そのままでよい。

#### 3.4. npmDepsHash を更新

`prefetch-npm-deps` で lockfile から直接計算できる（フルビルド不要）:

```bash
nix run nixpkgs#prefetch-npm-deps -- ./nix/pkgs/<pkg>-lock.json
```

出力された `sha256-...=` を `.nix` の `npmDepsHash` に貼る。フォールバック: `prefetch-npm-deps` が使えない環境では、`npmDepsHash` を `sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=` (44文字Aのダミー) に置いて `nix build .#checks.x86_64-linux.home-manager-build` を走らせ、エラー出力の `got: sha256-...` を採用する。

### 4. 種別Cの更新手順 (claude-code)

main と native の2本のtgzを同時更新する。バージョンは揃える前提。

```bash
eval "$(npm view "@anthropic-ai/claude-code@latest" version dist.tarball dist.integrity --json \
  | jq -r '"NEW_VER=\(.version)\nMAIN_URL=\(.dist.tarball)\nMAIN_SHA=\(.dist.integrity)"')"
eval "$(npm view "@anthropic-ai/claude-code-linux-x64@$NEW_VER" dist.tarball dist.integrity --json \
  | jq -r '"NATIVE_URL=\(.dist.tarball)\nNATIVE_SHA=\(.dist.integrity)"')"
echo "version=$NEW_VER"
echo "mainTgz: $MAIN_URL / $MAIN_SHA"
echo "nativeTgz: $NATIVE_URL / $NATIVE_SHA"
```

`nix/pkgs/claude-code.nix` の `version`, `mainTgz.{url,sha512}`, `nativeTgz.{url,sha512}` を書き換える。

native パッケージが新バージョンで未公開のケースがあるため、`@anthropic-ai/claude-code-linux-x64@$NEW_VER` の `npm view` がエラーになる場合は更新を中止し、ユーザーに報告する。

### 5. ビルド検証

更新後、以下のいずれかでビルドが通ることを確認する:

```bash
# home-manager 経由のビルド（種別B/Cの依存も同時に評価される）
nix build --no-link ./nix#checks.x86_64-linux.home-manager-build

# 全体検証
nix flake check ./nix
```

### 6. Post-Task Verification

CLAUDE.md (project) に従い、必ず以下を順に実行する:

```bash
nix run ./nix#lint && nix run ./nix#fmt && nix run ./nix#test
```

種別Aを更新した直後で `node_modules` が古い場合は `npm ci` を先に走らせる:
```bash
npm ci
```

### 7. 報告

全パッケージの結果をまとめて報告する（差分なしでスキップしたものも明記。コミット・プッシュは明示指示があるまでしない）:

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

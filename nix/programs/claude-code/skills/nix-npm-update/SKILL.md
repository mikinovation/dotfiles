---
name: nix-npm-update
description: nix管理下のnpm依存を最新化するスキル。package.jsonの通常依存、buildNpmPackage形式のラッパーパッケージ（vue-language-server, vue-typescript-plugin）、tgz直接展開形式（claude-code）の3種を扱う。「npmを最新化」「nixのnpm更新」「secretlintを上げて」「claude-code更新」「vue-language-server更新」などで使用。
---

# nix-npm-update: nix管理下のnpm依存更新スキル

このリポジトリにはnpm依存が3種類の形で存在する。それぞれ更新方法が異なるため、まず対象を特定してから手順を分岐させる。

## 対象の分類

| 種別 | 場所 | 形式 |
|------|------|------|
| A. 通常npm | `/package.json`, `/package-lock.json` | renovateで自動更新済。手動なら `npm update` |
| B. buildNpmPackage | `nix/pkgs/vue-language-server.nix`, `nix/pkgs/vue-typescript-plugin.nix` | tgz fetchUrl + 手書きlock + npmDepsHash |
| C. tgz直接展開 | `nix/pkgs/claude-code.nix` | mainTgz + nativeTgz (linux-x64) 2本立て |

## 手順

### 1. 対象を選択する

`AskUserQuestion` で対象パッケージを聞く。

- 質問: 「どのnpm依存を更新しますか」
- 選択肢:
  - `secretlint` — package.jsonのsecretlint一式 (種別A)
  - `vue-language-server` — 種別B
  - `vue-typescript-plugin` — 種別B
  - `claude-code` — 種別C
  - `all` — 全て順番に処理
  - `check-only` — 各パッケージの現行版と最新版の差分のみ表示して終了

`$ARGUMENTS` でパッケージ名が指定されている場合はその値を使い、この質問はスキップする。

### 2. 現行バージョンと最新バージョンを確認する

選択された対象ごとに以下を実行し、現行版/最新版を表示する。差分が無ければそのパッケージはスキップ。

種別A (secretlint):
```bash
CURRENT=$(grep -E '"secretlint"' package.json | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
LATEST=$(npm view secretlint version)
echo "secretlint: $CURRENT -> $LATEST"
```

種別B/C:
```bash
# vue-language-server / vue-typescript-plugin / @anthropic-ai/claude-code
CURRENT=$(grep -E '^\s*version\s*=' nix/pkgs/<pkg>.nix | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
LATEST=$(npm view <npm-package-name> version)
```

npm package名対応:
- vue-language-server → `@vue/language-server`
- vue-typescript-plugin → `@vue/typescript-plugin`
- claude-code (main) → `@anthropic-ai/claude-code`
- claude-code (native) → `@anthropic-ai/claude-code-linux-x64`

### 3. 種別Aの更新手順 (secretlint)

renovateで通常は自動化されているため、手動更新する正当な理由（renovateが止まっている、急ぎ等）を確認する。

```bash
npm update --save secretlint @secretlint/secretlint-rule-preset-recommend
npm install
```

`package.json` の version specifier が `^` 付きならば `--save-exact` を使うか否か既存に合わせる。現在の `package.json` は固定バージョン (`"13.0.0"` の形式) なので `--save-exact` 相当を維持する:

```bash
npm install --save-exact secretlint@latest @secretlint/secretlint-rule-preset-recommend@latest
```

検証は `Post-Task Verification` 節（後述）で実施する。

### 4. 種別Bの更新手順 (buildNpmPackage)

#### 4.1. 新tgzのURL/sha512を取得

```bash
NPM_PKG="@vue/language-server"     # または @vue/typescript-plugin
NEW_VER=$(npm view "$NPM_PKG" version)
TGZ_URL=$(npm view "$NPM_PKG@$NEW_VER" dist.tarball)
SHA512=$(npm view "$NPM_PKG@$NEW_VER" dist.integrity)
# SHA512 は "sha512-...=" 形式でそのまま .nix に貼れる
echo "version=$NEW_VER"
echo "url=$TGZ_URL"
echo "sha512=$SHA512"
```

#### 4.2. package-lock.json を再生成

リポジトリ内の `nix/pkgs/<pkg>-lock.json` を新バージョンで作り直す。

```bash
WORK=$(mktemp -d)
pushd "$WORK"
curl -sL "$TGZ_URL" -o pkg.tgz
mkdir -p src && tar xzf pkg.tgz -C src --strip-components=1
cd src
# 既存のlockがあれば削除して再生成
rm -f package-lock.json
npm install --package-lock-only --ignore-scripts
popd
cp "$WORK/src/package-lock.json" "nix/pkgs/<pkg>-lock.json"
```

`<pkg>` は `vue-language-server` か `vue-typescript-plugin`。

#### 4.3. .nix のメタ情報を更新

`nix/pkgs/<pkg>.nix` を編集する:

- `version` をNEW_VERへ
- `url` をTGZ_URLへ
- `sha512` をSHA512へ
- `npmDepsHash` を一旦 `lib.fakeHash` ではなく `""` (空文字) もしくは既存の値のままにせず、ビルドエラーから取得する

具体的には `npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";` のようなダミー値に置き換える（fakeHashの実値）。

#### 4.4. npmDepsHash を正しい値に置換

```bash
nix build .#packages.x86_64-linux.<attr> 2>&1 | tee /tmp/nix-build.log || true
# あるいは home-manager 経由でビルド
nix build .#homeConfigurations.nixos.activationPackage 2>&1 | tee /tmp/nix-build.log || true
NEW_HASH=$(grep -oE 'got:\s+sha256-[A-Za-z0-9+/=]+' /tmp/nix-build.log | tail -1 | awk '{print $2}')
echo "new npmDepsHash=$NEW_HASH"
```

`.nix` の `npmDepsHash` をこの値で置換し、再度ビルドして通ることを確認する。

代替手段: `prefetch-npm-deps` が利用できる場合は直接計算できる:
```bash
nix run nixpkgs#prefetch-npm-deps -- nix/pkgs/<pkg>-lock.json
```

### 5. 種別Cの更新手順 (claude-code)

main と native の2本のtgzを同時更新する。バージョンは揃える前提。

```bash
NEW_VER=$(npm view @anthropic-ai/claude-code version)

MAIN_URL=$(npm view "@anthropic-ai/claude-code@$NEW_VER" dist.tarball)
MAIN_SHA=$(npm view "@anthropic-ai/claude-code@$NEW_VER" dist.integrity)

NATIVE_URL=$(npm view "@anthropic-ai/claude-code-linux-x64@$NEW_VER" dist.tarball)
NATIVE_SHA=$(npm view "@anthropic-ai/claude-code-linux-x64@$NEW_VER" dist.integrity)

echo "version=$NEW_VER"
echo "mainTgz: $MAIN_URL / $MAIN_SHA"
echo "nativeTgz: $NATIVE_URL / $NATIVE_SHA"
```

`nix/pkgs/claude-code.nix` を編集:
- `version`
- `mainTgz.url`, `mainTgz.sha512`
- `nativeTgz.url`, `nativeTgz.sha512`

native パッケージが新バージョンで未公開のケースがあるため、`npm view @anthropic-ai/claude-code-linux-x64@$NEW_VER` がエラーになる場合は更新を中止し、ユーザーに報告する。

### 6. ビルド検証

更新後、以下のいずれかでビルドが通ることを確認する:

```bash
# 種別B/C を更新した場合（依存パッケージ単独ビルド）
nix build --no-link .#homeConfigurations.nixos.activationPackage

# 全体検証
nix flake check
```

### 7. Post-Task Verification

CLAUDE.md (project) に従い、必ず以下を順に実行する:

```bash
nix run ./nix#lint && nix run ./nix#fmt && nix run ./nix#test
```

種別Aを更新した直後で `node_modules` が古い場合は `npm ci` を先に走らせる:
```bash
npm ci
```

### 8. 報告

以下の形式で完了報告する（コミット・プッシュは明示指示があるまでしない）:

```
更新対象: <pkg名>
  <old> -> <new>
変更ファイル:
  - <path>
  - ...
ビルド: ok / fail
lint/fmt/test: ok / fail
```

## 注意

- renovateが種別Aを自動更新しているため、種別Aの手動更新はrenovateと競合する可能性がある。実行前に open PR を `gh pr list --search "secretlint"` で確認する。
- 種別Bのlockファイルは手書き再生成のため、上流の `package-lock.json` 仕様変更（lockfileVersion）に追随する必要があるケースがある。生成後にlockfileVersionを確認する。
- `npmDepsHash` のfakeHash用ダミー値は `sha256-AAAA...A=` (44文字のA) を使う慣習がある。
- `dontNpmBuild = true;` の指定があるため、`scripts` を実行せずにinstallのみ行う前提でlockを生成する。`--ignore-scripts` を必ず付ける。

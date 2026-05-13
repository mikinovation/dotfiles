---
name: gha-local-run
description: .github/workflows/*.yml からCI相当のjobを抽出してローカルのシェルで再現するスキル。lint/format/type-check/test/build/secret-scan などの静的チェックを対象とし、デプロイ系（release, publish, push to registry 等）は実行しない。「CIをローカルで」「workflowを試す」「github actionsをローカル実行」「ci-local」「pre-push相当の検証」「gha-local-run」などで使用。
---

# gha-local-run: GitHub Actions のCI相当処理をローカル再現するスキル

`.github/workflows/*.yml` から `jobs.*.steps[].run` を抽出し、シェルで直接実行する。`act` や Docker は使わない（ホスト環境で動くものに限る）。デプロイ系の job は実行候補に含めるが、警告マークを付け、最終判断はユーザーに委ねる。

## 対象スコープ

ローカルの静的チェックに該当するもののみ実行する。

| 種別 | 例 |
|------|-----|
| lint / format / type-check | eslint, prettier, tsc, ruff, gofmt, stylua, luacheck, rubocop |
| unit / integration test | vitest, jest, pytest, go test, cargo test, busted |
| build verification | npm run build, cargo build, go build（成果物の配布はしない） |
| secret / vuln scan | secretlint, trivy fs, semgrep, gitleaks |

明示的に除外する処理:

- 任意のレジストリへの push（npm publish, docker push, gh release create, cargo publish 等）
- クラウド資源の操作（aws-actions/configure-aws-credentials, gcp-auth, terraform apply 等）
- リポジトリへの書き込み（contents: write を使う action, タグ作成, リリース作成）

## 前提

- `.github/workflows/` が存在するリポジトリで実行する
- yml パーサは `yq-go` を `nix run nixpkgs#yq-go --` 経由で使う（ローカルに無くてもよい）
- `actions/checkout`, `actions/setup-*`, `actions/cache` 等の `uses:` ステップはスキップする。代わりに必要なツール（node, python, go 等）がローカルで実行可能か事前確認する

## 手順

### 1. workflow 一覧と job 構造を取り出す

```bash
YQ="nix run nixpkgs#yq-go --"
for f in .github/workflows/*.{yml,yaml}; do
  [ -f "$f" ] || continue
  echo "=== $f ==="
  $YQ '.name // "(no name)"' "$f"
  $YQ '.on | keys' "$f"
  $YQ '.permissions // "(none)"' "$f"
  $YQ '.jobs | to_entries | map({name: .key, job_name: .value.name, runs_on: .value.runs-on}) ' "$f"
done
```

### 2. 静的チェックっぽい job だけに絞って候補を出す

全 job を出すと数が増えて選びにくいので、以下の (A) 含める / (B) 除外する 2段フィルタを適用する。最終的に出すのは「(A) に該当し、かつ (B) に該当しない」job のみ。

#### (A) 含めるシグナル（1つ以上当てはまれば候補）

- job key / job name / workflow name のいずれかが正規表現 `(lint|format|fmt|prettier|type[-_ ]?check|tsc|test|spec|check|verify|validate|build|scan|audit|secret|security|sast)` にマッチ
- step の `uses:` に `reviewdog/`, `github/codeql-action/`, `aquasecurity/trivy-action`, `returntocorp/semgrep-action`, `gitleaks/gitleaks-action` 等の静的解析系 action がある
- step の `run:` が以下の代表的なコマンドを含む（部分一致）:
  - JS/TS: `eslint`, `prettier`, `tsc`, `vitest`, `jest`, `playwright`, `vue-tsc`, `biome`, `oxlint`
  - Python: `ruff`, `flake8`, `mypy`, `pyright`, `black`, `pytest`, `tox`
  - Go: `go test`, `go vet`, `golangci-lint`, `gofmt`, `staticcheck`
  - Rust: `cargo test`, `cargo clippy`, `cargo fmt`, `cargo check`
  - Ruby: `rubocop`, `rspec`, `bundle exec rake test`, `standardrb`
  - Nix/Lua: `nix flake check`, `statix`, `nixpkgs-fmt`, `alejandra`, `luacheck`, `stylua`
  - Security/Secret: `secretlint`, `trivy`, `semgrep`, `gitleaks`, `bandit`
  - Build verification: `npm run build`, `pnpm build`, `yarn build`, `cargo build`, `go build`

#### (B) 除外するシグナル（1つでも当てはまれば候補から外す）

- workflow / job 名が正規表現 `(deploy|release|publish|upload|push-to-|cd\b|delivery|pages|docker-push)` にマッチ
- `on:` が `release`, `workflow_dispatch` のみ、または `push.tags` を持つ（PR / branch push トリガーが無い）
- `permissions:` に `id-token: write`, `contents: write`, `packages: write`, `pages: write` のいずれか
- step の `uses:` が以下のいずれかにマッチ:
  - `aws-actions/configure-aws-credentials`
  - `google-github-actions/auth`
  - `docker/login-action`, `docker/build-push-action`
  - `softprops/action-gh-release`, `actions/create-release`, `ncipollo/release-action`
  - `JS-DevTools/npm-publish`, `cycjimmy/semantic-release-action`, `googleapis/release-please-action`
- step の `run:` に以下のコマンド:
  - `npm publish`, `yarn publish`, `pnpm publish`, `cargo publish`, `gem push`, `mvn deploy`, `gradle publish`
  - `gh release create`, `gh release upload`
  - `docker push`, `aws s3 cp`, `gcloud`, `kubectl apply`, `helm upgrade`, `terraform apply`
  - `gh pages`, `firebase deploy`, `vercel`, `netlify deploy`

#### 提示

絞り込んだ候補だけを番号付きで出す:

```
[1] ci.yml :: lint    (eslint, prettier)
[2] ci.yml :: test    (vitest)
[3] ci.yml :: build   (npm run build)
```

そのうえで「除外したものは表示しない代わりに件数だけ出す」:

```
除外: 2件 (release.yml::publish, deploy.yml::deploy-prod)
```

ユーザーが除外分も見たい / 実行したい場合は明示的に求められたら全件出す。フィルタが空（候補ゼロ）になった場合は、フィルタを外して全 job を出し、ユーザーに選ばせる（フィルタの誤検知で完全に何も実行できないのを防ぐ）。

### 3. 選ばれた job の step を抽出する

`uses:` のステップは原則スキップする。ただし以下は対応する:

- `actions/checkout` → そもそも作業ツリーで実行しているのでスキップ
- `actions/setup-node`, `actions/setup-python`, `actions/setup-go`, `actions/setup-ruby` → ローカルに該当バージョンがあるか確認する。無ければ警告して中断するか、ユーザーに続行確認する
- `actions/cache` → スキップ（ローカル実行では不要）

`run:` のステップは以下を保持しつつ抽出する:

- `working-directory`（無ければ job の `defaults.run.working-directory`、それも無ければリポジトリルート）
- `env`（job レベル env + step レベル env をマージ、step が勝つ）
- `shell`（`bash`, `sh`, `pwsh` 等。指定が無ければ `bash`）

`matrix` がある場合は組合せをユーザーに提示して1つ選ばせる。全組合せを自動で回さない（時間がかかるため）。

抽出例:

```bash
JOB=lint
WF=.github/workflows/ci.yml
$YQ ".jobs.${JOB}.steps[] | select(has(\"run\")) | {wd: .working-directory, env: .env, shell: .shell, run: .run}" "$WF"
```

### 4. 実行する

step を1つずつ順に実行する。各 step ごとに:

```bash
( cd "$WD" && env "$ENV_VARS" "$SHELL" -e -c "$RUN" )
```

ポイント:

- `-e` を付けて失敗時にその step で停止する
- `${{ github.* }}` 等の expression を含む step は警告する（簡易展開のみ対応、`${{ github.sha }}` は `git rev-parse HEAD`、`${{ github.ref_name }}` は `git rev-parse --abbrev-ref HEAD` 等で代替）
- secrets を参照する step は中断する（`${{ secrets.* }}` が見えたら止める）。ユーザーが手動で値を渡せるなら環境変数として export してもらってから再開する

### 5. 結果を報告する

報告フォーマット:

```
対象: <workflow>::<job>
実行 step:
  - <step name>: ok / fail / skip(uses)
  - ...
失敗 step がある場合: 最初の失敗の stderr 末尾 20 行を要約
所要時間: <秒>
```

## 注意

- このスキルは GHA を厳密に再現するものではない。`actions/*` を使う step はスキップするため、ローカルで再現できない処理は明示的に報告する
- `matrix` の全組合せ実行はしない。代表1つに絞る
- `secrets.*` を含む step は実行しない。CI でしか検証できないものを誤って動かさないため
- 候補フィルタはあくまでヒューリスティクス。本来含めたい job が除外されることがあり得る。候補が空になったとき、またはユーザーが「他にあるはず」と言ったときは、除外分の理由と一緒に全件を提示する
- `permissions` 句が無い workflow はデフォルトで `contents: read` 扱い。`permissions` 自体が無いことは deploy 判定の根拠にしない
- ホスト OS が `runs-on: ubuntu-latest` と異なる場合（macOS, Windows 指定 job 等）は警告する。シェルや改行コード由来の差異が出る

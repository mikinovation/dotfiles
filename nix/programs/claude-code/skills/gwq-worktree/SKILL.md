---
name: gwq-worktree
description: gwqでgit worktreeを作成・一覧・パス取得・削除し、動作確認用ブランチをMain Worktreeに反映してローカル確認用に運用するスキル。worktreeはghqミラー型の~/worktrees/<host>/<owner>/<repo>/<branch>に配置する。「worktree作って」「gwqでworktree」「新しいworktree」「worktree一覧」「worktree削除」「動作確認用ブランチ」「ローカル確認」「main worktreeに反映」「/gwq-worktree」「ブランチ用の作業ツリー」などで使用。
---

# gwq-worktree: git worktree運用スキル

`gwq` を使って worktree を作成・一覧・削除する。worktree は ghq と並列の構造化ディレクトリ
`~/worktrees/<host>/<owner>/<repo>/<branch>` に配置される。

重要な制約: このスキルが `Bash` で実行するコマンドはユーザーの対話シェルとは別プロセスのため、
`gwq cd` でユーザーのシェルのカレントディレクトリを移動させることはできない。
切替（移動）はパスを提示し、ユーザー自身に `gwq cd <branch>` または `cd <path>` を実行してもらう。

## 手順

### 1. 前提を確認する

カレントが git リポジトリ内であることを確認する。

```bash
git rev-parse --is-inside-work-tree
```

`true` でない場合は「git リポジトリ内で実行してください」と伝えて終了する。

### 2. 操作を確定する

`$ARGUMENTS` から操作が明確な場合（例: 「一覧」「削除」「作って」）はそれに従う。
不明な場合は `AskUserQuestion` で選択させる。

- 質問: 「gwq worktree で何をしますか？」
- 選択肢:
  - `作成` — 新しいブランチの worktree を作る
  - `一覧` — worktree 一覧を表示する
  - `パス取得` — 既存 worktree のパスを取得する（移動用）
  - `動作確認` — 指定 worktree の内容を Main Worktree に反映してローカル確認する
  - `削除` — worktree を削除する

操作に応じて以降のステップへ進む。

### 3-A. 作成

#### 3-A-1. ブランチ名を決める

ブランチ作成は worktree 作成と一体で行う（このスキルが唯一のブランチ作成経路）。

`$ARGUMENTS` にブランチ説明があればそれを使う。無ければ `AskUserQuestion` で prefix と説明を入力させる。

- prefix の選択肢: `feature` / `fix` / `chore` / `docs` / `refactor` / `test` / `style` / `perf` / `ci` / `build` / `revert` / `custom`
  - `custom` を選んだ場合は `AskUserQuestion` で自由入力させ `PREFIX` に格納する。
  - それ以外は選択値を `PREFIX` に格納する。
- 説明（タイトル）が日本語の場合はまず英語に翻訳する（自分で翻訳する。外部ツール不要）。
  翻訳した英語を kebab-case に正規化する。

```bash
BRANCH_DESC=$(printf '%s' "$ENGLISH_TITLE" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g; s/-{2,}/-/g')
BRANCH="${PREFIX}/${BRANCH_DESC}"
```

例: 「ログイン機能追加」→ `feature/add-login-feature`、「認証エラー修正」→ `fix/fix-auth-error`

#### 3-A-2. worktree を作成する

新規ブランチを切って worktree を作る（`-b`）。

```bash
gwq add -b "$BRANCH"
```

既存ブランチから作る場合は `-b` を外す（`gwq add "$BRANCH"`）。
失敗した場合はエラーを表示し原因を説明する。

#### 3-A-3. 結果を報告する

作成した worktree のパスを取得して提示する。

```bash
gwq get "$BRANCH"
```

「worktree `{BRANCH}` を `{パス}` に作成しました。移動するにはご自身のシェルで
`gwq cd {BRANCH}` を実行してください」と報告する。

### 3-B. 一覧

```bash
gwq list -v
```

出力をそのまま提示する。`--json` が必要な用途（スクリプト連携）の場合のみ `gwq list --json` を使う。

### 3-C. パス取得（移動用）

`$ARGUMENTS` にパターンがあればそれを、無ければ一覧を見せてからパターンを `AskUserQuestion` で確認する。

```bash
gwq get "$PATTERN"
```

取得したパスを提示し、「ご自身のシェルで `gwq cd {PATTERN}` を実行すると移動できます」と伝える。
このスキルからはユーザーのシェルを移動できないことを明示する。

### 3-E. 動作確認（ローカル確認用運用）

参考: https://blog.atusy.net/2026/02/02/git-worktree-local-deploy/

#### 考え方

複数 worktree を並行運用すると、各々で dev サーバを立てると URL・ポートが競合し、認知負荷とリソースを浪費する。
これを避けるため、確認の起点を Main Worktree 1 つに固定する。

- Main Worktree（gwq/ghq では元クローン `~/ghq/<host>/<owner>/<repo>`、`git worktree list` の先頭）を
  ローカル確認専用にする。開発作業はここで行わない。
- Main Worktree で `pnpm run dev` / `cargo watch` 等のホットリロード付きコマンドを起動しておく。
- 動作確認したいブランチは worktree（`~/worktrees/...`）で開発し、その内容を Main Worktree に反映して確認する。
  dev サーバは 1 つだけなので競合が起きない。

#### 手順

1. 確認対象ブランチの worktree を用意する。無ければ 3-A で `gwq add -b "$BRANCH"` で作成し、その worktree に cd する
   （または `gwq get "$BRANCH"` でパスを取得しそこへ移動する）。
2. Main Worktree のパスを取得する。

   ```bash
   MAIN_WORKTREE_DIR="$(git worktree list --porcelain | head -n 1 | sed -e 's/^worktree //')"
   ```

3. 反映方法を確定する。
   - コミット済みの内容だけで足りる場合は detached checkout で反映する。

     ```bash
     git -C "$MAIN_WORKTREE_DIR" checkout --detach "$(git rev-parse HEAD)"
     ```

   - 未コミットの変更や gitignore 対象ファイルも反映したい場合は、上記に続けて rsync で同期する。
     `--delete` は同期先（Main Worktree）の余分なファイルを消すため、必ず先に `-n`（dry-run）で対象を提示し、
     ユーザーに実行可否を `AskUserQuestion` で確認してから本実行する。`.git/` は必ず除外する。

     ```bash
     # まず dry-run で差分を提示
     rsync -a --delete --exclude '.git/' -n "$PWD/" "$MAIN_WORKTREE_DIR/"
     # 了承後に本実行
     rsync -a --delete --exclude '.git/' "$PWD/" "$MAIN_WORKTREE_DIR/"
     ```

4. Main Worktree で起動中の dev サーバがホットリロードで反映するので、そこで動作確認する。

#### 注意

- Main Worktree の HEAD は detached になる。Main Worktree では開発（コミット）作業をしない前提で運用する。
- `rsync --delete` の同期先が Main Worktree であることを必ず確認する。誤ったディレクトリを指定すると破壊的。
- 確認が終わったら Main Worktree を元のブランチに戻す。

  ```bash
  git -C "$MAIN_WORKTREE_DIR" checkout <元のブランチ>
  ```

### 3-D. 削除

削除対象を確認する。`$ARGUMENTS` にパターンがあればそれを使い、無ければまず一覧を見せる。
破壊的操作のため、必ず先に dry-run で対象を確認し、ユーザーに削除可否を `AskUserQuestion` で確認してから実行する。

```bash
# まず対象を確認
gwq remove --dry-run "$PATTERN"
```

ユーザーが了承したら削除する。

```bash
gwq remove "$PATTERN"
```

ブランチも一緒に削除したい旨が明示された場合のみ `-b`（`gwq remove -b "$PATTERN"`）を付ける。
未マージで削除できない等のエラーは内容を説明し、`--force-delete-branch` の使用可否はユーザーに確認する。

## 注意

- worktree の配置先は `~/.config/gwq/config.toml` の `worktree.basedir`（既定 `~/worktrees`）に従う。
- `gwq cd` / `gwq add -s` のシェル移動はシェル統合（`cd.launch_shell = false` + `source <(gwq completion zsh)`）に依存し、ユーザーの対話シェルでのみ機能する。スキルからは行わない。

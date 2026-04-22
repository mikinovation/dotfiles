---
name: commit-commands:create-branch
description: ブランチを作成するスキル。feat, fix, chore等の一般的なprefixを選択するか、カスタムprefixを自由入力し、現在のブランチから新しいブランチを作成する。「ブランチを作って」「新しいブランチ」「create branch」「/create-branch」「branch作成」などで使用。
---

# commit-commands:create-branch: ブランチ作成スキル

現在のブランチから、prefix付きの新しいブランチを作成します。

## 手順

### 1. 引数を確認する

`$ARGUMENTS` が指定されている場合はそれをブランチの説明（タイトル）として使用し、ステップ2へ進む。
指定されていない場合はステップ2でprefixを選択した後、ステップ4でタイトルを入力させる。

### 2. prefixをAskUserQuestionで選択する

`AskUserQuestion` ツールを使い、以下の選択肢を提示する:

- 質問: 「ブランチのprefixを選択してください」
- 選択肢 (options フィールドに配列で渡す):
  - `feat` — 新機能
  - `fix` — バグ修正
  - `chore` — 雑務・設定変更
  - `docs` — ドキュメント
  - `refactor` — リファクタリング
  - `test` — テスト追加・修正
  - `style` — コードスタイル（ロジック変更なし）
  - `perf` — パフォーマンス改善
  - `ci` — CI/CD
  - `build` — ビルド関連
  - `revert` — リバート
  - `custom` — カスタム入力

### 3. prefixを確定する

- ユーザーが「custom」を選択した場合: `AskUserQuestion` で自由入力させる
  - 質問: 「カスタムprefixを入力してください（例: hotfix, spike, wip）」
- それ以外: 選択されたprefixをそのまま使用する

### 4. ブランチ説明を確定する

- `$ARGUMENTS` が指定されていた場合: その値をタイトルとして使用し、このステップはスキップする
- 指定されていない場合: `AskUserQuestion` でタイトルを入力させる
  - 質問: 「ブランチ名の説明を入力してください（日本語可、例: ログイン機能追加）」

タイトルが日本語の場合はまず英語に翻訳する（あなた自身が翻訳する。外部ツールは不要）。
翻訳した英語をkebab-caseに正規化する:
```bash
BRANCH_DESC=$(printf '%s' "$ENGLISH_TITLE" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g; s/-{2,}/-/g')
```

例:
- 「ログイン機能追加」 → `add-login-feature`
- 「認証エラー修正」 → `fix-auth-error`

ブランチ名は `{prefix}/{BRANCH_DESC}` の形式にする。

### 5. 現在のブランチを確認してブランチを作成する

```bash
CURRENT_BRANCH=$(git branch --show-current)
NEW_BRANCH="{prefix}/{BRANCH_DESC}"
git checkout -b "$NEW_BRANCH"
```

作成に成功したら「ブランチ `{新しいブランチ名}` を `{現在のブランチ}` から作成しました」と報告する。
エラーが発生した場合はエラーメッセージを表示し、原因を説明する。

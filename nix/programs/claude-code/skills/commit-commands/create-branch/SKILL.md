---
name: commit-commands:create-branch
description: ブランチを作成するスキル。feat, fix, chore等の一般的なprefixを選択するか、カスタムprefixを自由入力し、現在のブランチから新しいブランチを作成する。「ブランチを作って」「新しいブランチ」「create branch」「/create-branch」「branch作成」などで使用。
---

# commit-commands:create-branch: ブランチ作成スキル

現在のブランチから、`${PREFIX}/${BRANCH_DESC}` 形式の新しいブランチを作成します。

## 手順

### 1. prefixを決める

`AskUserQuestion` ツールで「ブランチのprefixを選択してください」と尋ね、以下を options フィールドに配列で渡す:

- `feature` — 新機能
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

`custom` が選ばれた場合は、`AskUserQuestion` で「カスタムprefixを入力してください（例: hotfix, spike, wip）」と尋ねて自由入力させる。確定した値を `PREFIX` に格納する。

### 2. ブランチ説明を決める

`$ARGUMENTS` が指定されていればその値をタイトルとして使う。指定されていなければ、`AskUserQuestion` で「ブランチ名の説明を入力してください（日本語可、例: ログイン機能追加）」と尋ねる。

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

### 3. ブランチを作成する

```bash
CURRENT_BRANCH=$(git branch --show-current)
NEW_BRANCH="${PREFIX}/${BRANCH_DESC}"
git checkout -b "$NEW_BRANCH"
```

成功したら「ブランチ `{新しいブランチ名}` を `{現在のブランチ}` から作成しました」と報告する。
エラーが発生した場合はエラーメッセージを表示し、原因を説明する。

---
name: commit-commands:create-pr
description: プルリクエストを作成するスキル。commit-push-pr の流れ（ブランチ作成→コミット→push→gh pr create）を踏襲し、PRのタイトルと本文を書く言語を選択させ、リポジトリのPRテンプレートに沿った下書きを確認してから Draft PR を作成する。「PRを作って」「プルリクを作成」「create pr」「/create-pr」「PR作成」などで使用。
---

# commit-commands:create-pr: プルリクエスト作成スキル

commit-commands の `/commit-push-pr` と同じ流れ（ブランチ作成、コミット、push、`gh pr create`）で、現在のブランチから PR を作成する。`/commit-push-pr` との違いは次の4点である。

- PR のタイトルと本文を書く言語を選択させる
- リポジトリの PR テンプレートに沿って本文を書く
- 作成前に下書きを提示し、承認を得てから作成する
- 常に Draft PR として作成する

## 手順

### 1. 言語を決める

`$ARGUMENTS` で言語が指定されていれば（例: `ja`, `en`, `日本語`, `English`）その言語を使い、質問しない。

指定されていなければ、`AskUserQuestion` ツールで「PRのタイトルと本文を書く言語を選択してください」と尋ね、以下を options フィールドに配列で渡す:

- `日本語`
- `English`
- `custom` — その他の言語を自由入力

`custom` が選ばれた場合は、`AskUserQuestion` で「言語を入力してください（例: 中文, 한국어, Français）」と尋ねて自由入力させる。確定した値を `LANGUAGE` とする。

### 2. 状態を確認する

```bash
git status
git branch --show-current
BASE_BRANCH=$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name)
git fetch origin "$BASE_BRANCH"
gh pr view --json url,state 2>/dev/null
```

`gh pr view` の `state` が `OPEN` の場合は、その URL を示して終了する。新しい PR は作らない。`MERGED` や `CLOSED` の PR しかない場合は続ける。

### 3. ブランチを用意する

現在のブランチが `BASE_BRANCH` の場合は、`Skill` ツールで `commit-commands:create-branch` を呼んでブランチを作成する。それ以外のブランチでは何もしない。

### 4. 未コミットの変更をコミットする

`git status` に未コミットの変更がある場合は、`Skill` ツールで `commit` を呼んでコミットする。変更がなければ飛ばす。

`BASE_BRANCH` との差分にコミットが1つもない場合は、PR にする変更がないことを伝えて終了する。

### 5. 変更内容を把握する

PR に含まれる全コミットと差分を読む。最新のコミットだけで判断しない。

```bash
git log --oneline "origin/${BASE_BRANCH}..HEAD"
git diff "origin/${BASE_BRANCH}...HEAD"
```

### 6. タイトルと本文の下書きを作る

PR テンプレートを次の順で探し、最初に見つかったものを使う:

1. `.github/pull_request_template.md`
2. `.github/PULL_REQUEST_TEMPLATE.md`
3. `.github/PULL_REQUEST_TEMPLATE/` 内のファイル（複数あれば `AskUserQuestion` で選ばせる）
4. `PULL_REQUEST_TEMPLATE.md`
5. `docs/pull_request_template.md`, `docs/PULL_REQUEST_TEMPLATE.md`

タイトルと本文は `LANGUAGE` で書く。

- タイトル: 変更内容を一文で要約する。リポジトリのコミットが Conventional Commits 形式（`feat:`, `fix(scope):` など）なら、同じ prefix を付け、prefix 以降を `LANGUAGE` で書く
- テンプレートがある場合: 見出しと構成はテンプレートのまま残し、各節の中身を `LANGUAGE` で埋める。HTML コメント（`<!-- -->`）の指示は埋めたら削除する。埋める材料がない節は空欄のまま残し、手順7で尋ねる
- テンプレートがない場合: 「概要」「変更内容」「確認方法」の3節で書き、見出しも `LANGUAGE` で書く
- 関連 Issue は、ブランチ名とコミットメッセージに Issue 番号があればそれを使う。なければ推測しない

差分とコミットから読めない事実（動機、確認手順の結果など）は補わない。

### 7. 下書きを確認する

タイトルと本文の下書きを提示する。材料のない節は、下書きの後に挙げて、書く内容を尋ねる。回答を反映してから、`AskUserQuestion` で「この内容で Draft PR を作成してよいですか」と尋ね、以下を options に渡す:

- `作成する`
- `修正する` — 修正内容を自由入力

`修正する` が選ばれた場合は、指示に沿って下書きを直し、再度確認する。承認が得られるまで PR を作成しない。承認されたタイトルを `TITLE` とする。

### 8. push して Draft PR を作成する

```bash
git push -u origin "$(git branch --show-current)"
gh pr create --draft --base "$BASE_BRANCH" --title "$TITLE" --body "$(cat <<'EOF'
<本文>
EOF
)"
```

成功したら PR の URL を報告する。エラーが発生した場合はエラーメッセージを表示し、原因を説明する。

## このスキルで扱わないこと

- レビュアーやラベル、マイルストーンの設定
- Draft から Ready for review への切り替え
- PR 作成後の CI 監視とレビュー対応

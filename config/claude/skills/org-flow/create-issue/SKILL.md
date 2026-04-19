---
name: org-log
description: 作業内容をorg-mode形式で記録するスキル。タスク完了時・セッション終了時・コミット後・PR作成後など、何らかの作業が一段落したタイミングで必ず使用する。ユーザーが「/org-log」「ログ書いて」「orgに記録」「作業まとめ」「refile」「作業ログ」と言った場合はもちろん、CLAUDE.mdで作業完了後の実行が指示されている場合も必ずこのスキルを使用すること。セッションログとrefile.orgインデックスの2箇所に書き込む。
---

# org-log: 作業ログをorg-modeに記録

セッションログを **ghqと同じディレクトリ構造** で記録し、`refile.org` にはリンク付きインデックスのみ追記する。

## 手順

### 1. ブランチを作成する

作業を開始する前に、以下のコマンドでブランチを作成するようユーザーに指示する:

```bash
git checkout -b {ブランチ名}
```

ブランチ名は作業内容を表す英語のkebab-caseにする（例: `fix-login-bug`, `add-user-api`）。
ユーザーがブランチ名を指定していない場合は、作業内容から提案する。
ブランチ作成を確認してから次のステップに進む。

### 2. 不足情報をユーザーに確認する

以下のプロパティのうち不明なものを `AskUserQuestion` ツールで確認する（1回の呼び出しで最大4問まとめて質問する）:

- ブランチ名（ステップ1でまだ確定していない場合）
- チケットURL（GitHub Issue、Jira、NotionなどのURL）

質問の例:
- ブランチ名が未定: 「ブランチ名を教えてください」/ 選択肢として作業内容から候補を提案する
- チケットURL: 「関連するチケットのURLはありますか？」/ 選択肢: 「あり（入力）」「なし」

既にユーザーが情報を提供済みの場合はこのステップをスキップする。

### 3. 作業内容を振り返る

現在のセッションで行った作業を振り返り、以下を整理する:
- 作業の目的（見出しに使う簡潔なタイトル）
- 具体的に何をしたか（箇条書き）

### 4. セッション情報を取得する

以下のコマンドでセッションIDとリポジトリパスを取得する:

```bash
# プロジェクト名: pwdのパスを`-`区切りに変換（先頭の/も-に）
PROJECT_NAME=$(pwd | sed 's|/|-|g')
# 最新のjsonlファイルを取得
LATEST_JSONL=$(find "${HOME}/.claude/projects/${PROJECT_NAME}" -maxdepth 1 -type f -name '*.jsonl' 2>/dev/null | xargs -r ls -t 2>/dev/null | head -n 1)
if [ -z "${LATEST_JSONL}" ]; then
  echo "ERROR: セッションログが見つからないため org-log を中断します" >&2
  exit 1
fi
# 最新のjsonlファイル名（拡張子なし）がセッションID
SESSION_ID=$(basename "${LATEST_JSONL}" .jsonl)
# ghqルートからの相対パスを取得（例: github.com/mikinovation/dotfiles）
GHQ_ROOT="${HOME}/ghq"
CURRENT_DIR=$(pwd)
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "${REPO_ROOT}" ]; then
  echo "ERROR: not inside a git repository, aborting org-log" >&2
  exit 1
fi
case "${REPO_ROOT}" in
  "${GHQ_ROOT}"/*) ;;
  *)
    echo "ERROR: repository root is not under ${GHQ_ROOT}/, aborting org-log: ${REPO_ROOT}" >&2
    exit 1
    ;;
esac
REPO_REL_PATH="${REPO_ROOT#${GHQ_ROOT}/}"
TODAY=$(date +%Y%m%d)
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
BASE_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')
if [ -z "$BASE_BRANCH" ]; then
  BASE_BRANCH=$(git branch -r 2>/dev/null | grep -E 'origin/(main|master)$' | head -1 | sed 's|.*origin/||; s|^[[:space:]]*||')
fi
echo "SESSION_ID: $SESSION_ID"
echo "DIR: $CURRENT_DIR"
echo "REPO_ROOT: $REPO_ROOT"
echo "REPO_REL_PATH: $REPO_REL_PATH"
echo "TODAY: $TODAY"
echo "CURRENT_BRANCH: $CURRENT_BRANCH"
echo "BASE_BRANCH: $BASE_BRANCH"
```

### 5. セッションログファイルに追記する

書き込み先: `~/ghq/github.com/mikinovation/org/journal/{REPO_REL_PATH}/{TODAY}-{TITLE_SLUG}.org`

TITLE_SLUGは作業タイトルを英語のkebab-caseに変換したもの（例: 「Notion MCP移行」→ `notion-mcp-migration`）。
生成ルール:
```bash
TITLE_SLUG=$(printf '%s' "$WORK_TITLE" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g; s/-{2,}/-/g')
```

例:
- タイトル「fix login bug」で `~/ghq/github.com/mikinovation/dotfiles` → `journal/github.com/mikinovation/dotfiles/20260407-fix-login-bug.org`
- タイトル「add user api」で `~/ghq/github.com/foo/bar` → `journal/github.com/foo/bar/20260408-add-user-api.org`

ディレクトリが存在しない場合は `mkdir -p` で作成する。

以下のフォーマットでファイル末尾に追記する。既存の内容は絶対に変更しない:

```org
* TODO {作業タイトル}
:PROPERTIES:
:DIR: {ワークスペースのディレクトリパス}
:SESSION_ID: {取得したセッションID}
:CURRENT_BRANCH: {現在のブランチ名}
:BASE_BRANCH: {ベースブランチ名}
:TICKET: {チケットのURL（なければ空欄）}
:END:
- {やったこと1}
- {やったこと2}
- 再開コマンド:
#+begin_src shell
cd {ワークスペースのディレクトリパス}
claude --resume {セッションID}
#+end_src
```

ファイルが存在しない場合は、先頭に `#+TITLE:` を付けて新規作成する:
```org
#+TITLE: {作業タイトル} - {REPO_REL_PATH}
```

### 6. refile.orgにリンク付きインデックスを追記する

`~/ghq/github.com/mikinovation/org/refile.org` の末尾に、セッションログへのリンクのみ追記する:

```org
* TODO {作業タイトル}
[[file:~/ghq/github.com/mikinovation/org/journal/{REPO_REL_PATH}/{TODAY}-{TITLE_SLUG}.org::*{作業タイトル}][セッション詳細]]
```

**重要**: refile.orgには詳細を書かない。リンクのみ。

### 7. 完了報告

追記した内容を表示して完了を報告する。

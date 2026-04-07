---
name: org-log
description: 作業内容をorg-mode形式で記録するスキル。タスク完了時・セッション終了時・コミット後・PR作成後など、何らかの作業が一段落したタイミングで必ず使用する。ユーザーが「/org-log」「ログ書いて」「orgに記録」「作業まとめ」「refile」「作業ログ」と言った場合はもちろん、CLAUDE.mdで作業完了後の実行が指示されている場合も必ずこのスキルを使用すること。セッションログとrefile.orgインデックスの2箇所に書き込む。
---

# org-log: 作業ログをorg-modeに記録

セッションログを **ghqと同じディレクトリ構造** で記録し、`refile.org` にはリンク付きインデックスのみ追記する。

## 手順

### 1. 作業内容を振り返る

現在のセッションで行った作業を振り返り、以下を整理する:
- 作業の目的（見出しに使う簡潔なタイトル）
- 具体的に何をしたか（箇条書き）

### 2. セッション情報を取得する

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
REPO_REL_PATH=$(echo "${CURRENT_DIR}" | sed "s|${GHQ_ROOT}/||")
TODAY=$(date +%Y%m%d)
echo "SESSION_ID: $SESSION_ID"
echo "DIR: $CURRENT_DIR"
echo "REPO_REL_PATH: $REPO_REL_PATH"
echo "TODAY: $TODAY"
```

### 3. セッションログファイルに追記する

書き込み先: `~/ghq/github.com/mikinovation/org/journal/{REPO_REL_PATH}/{TODAY}-{TITLE_SLUG}.org`

TITLE_SLUGは作業タイトルを英語のkebab-caseに変換したもの（例: 「Notion MCP移行」→ `notion-mcp-migration`）。

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
:END:
- {やったこと1}
- {やったこと2}
- 再開コマンド:
#+begin_src shell
cd {ワークスペースのディレクトリパス}
claude --continue {セッションID}
#+end_src
```

ファイルが存在しない場合は、先頭に `#+TITLE:` を付けて新規作成する:
```org
#+TITLE: {作業タイトル} - {owner}/{repo}
```

### 4. refile.orgにリンク付きインデックスを追記する

`~/ghq/github.com/mikinovation/org/refile.org` の末尾に、セッションログへのリンクのみ追記する:

```org
* TODO {作業タイトル}
[[file:journal/{REPO_REL_PATH}/{TODAY}-{TITLE_SLUG}.org::*{作業タイトル}][セッション詳細]]
```

**重要**: refile.orgには詳細を書かない。リンクのみ。

### 5. 完了報告

追記した内容を表示して完了を報告する。

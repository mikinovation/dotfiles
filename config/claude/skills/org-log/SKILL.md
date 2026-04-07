---
name: org-log
description: 作業内容をorg-mode形式でrefile.orgに記録するスキル。タスク完了時・セッション終了時・コミット後・PR作成後など、何らかの作業が一段落したタイミングで必ず使用する。ユーザーが「/org-log」「ログ書いて」「orgに記録」「作業まとめ」「refile」「作業ログ」と言った場合はもちろん、CLAUDE.mdで作業完了後の実行が指示されている場合も必ずこのスキルを使用すること。作業の要約・ワークスペース情報・セッションID・再開コマンドをorg-mode形式で自動追記する。
---

# org-log: 作業ログをorg-modeに記録

現在のセッションで行った作業内容を `~/ghq/github.com/mikinovation/org/refile.org` にorg-mode形式で追記する。

## 手順

### 1. 作業内容を振り返る

現在のセッションで行った作業を振り返り、以下を整理する:
- 作業の目的（見出しに使う簡潔なタイトル）
- 具体的に何をしたか（箇条書き）

### 2. セッション情報を取得する

以下のコマンドでセッションIDを取得する:

```bash
# プロジェクト名: pwdのパスを`-`区切りに変換（先頭の/も-に）
PROJECT_NAME=$(pwd | sed 's|/|-|g')
# 最新のjsonlファイル名（拡張子なし）がセッションID
SESSION_ID=$(ls -t ~/.claude/projects/${PROJECT_NAME}/*.jsonl 2>/dev/null | head -1 | xargs -I{} basename {} .jsonl)
echo "SESSION_ID: $SESSION_ID"
echo "DIR: $(pwd)"
```

### 3. refile.orgに追記する

以下のフォーマットでファイル末尾に追記する。既存の内容は絶対に変更しない。

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

ファイルパス: `~/ghq/github.com/mikinovation/org/refile.org`

追記には `>>` リダイレクトまたはファイル末尾へのEditを使う。ファイルが存在しない場合は新規作成する。

### 4. 完了報告

追記した内容を表示して完了を報告する。

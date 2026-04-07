- 常に日本語で回答してください。
- 作業完了後、対応内容を `~/ghq/github.com/mikinovation/org/refile.org` にorg-mode形式で追記してください。以下の情報を含めること:
  - 作業内容の要約
  - ワークスペースのディレクトリパス
  - セッションID: `pwd`のパスを`-`区切りに変換（先頭の`/`も`-`に）したものをプロジェクト名として、`ls -t ~/.claude/projects/<project-name>/*.jsonl | head -1` で最新のjsonlファイル名（拡張子除く）を取得
  - 記載例:

```org
* TODO CLAUDE.mdにorg-mode記録の指示を追加
:PROPERTIES:
:DIR: ~/ghq/github.com/mikinovation/dotfiles
:SESSION_ID: c7023d70-1e6e-4255-b933-5dcbfc3d9de4
:END:
- config/claude/CLAUDE.mdに作業ログをrefile.orgへ記録する指示を追加
- セッションIDとワークスペース情報を含めるようにした
- 再開コマンド:
#+begin_src shell
cd ~/ghq/github.com/mikinovation/dotfiles
claude --continue c7023d70-1e6e-4255-b933-5dcbfc3d9de4
#+end_src
```

---
name: create-prd
description: PRD（要求定義ドキュメント）を docs/prd/ に作成・更新するスキル。次の連番を採番し、テンプレートを埋め、索引を更新する。Draft/Shipped/Dropped のステータス更新も行う。「PRDを書いて」「要件定義を作成」「create prd」「/create-prd」「PRDをShippedにして」などで使用。
---

# create-prd: PRD作成スキル

`docs/prd/` に要求定義を1ファイル追加、または既存PRDのステータスを更新する。
PRDは「何を作るか・どうなったら完了か」を書く。どの設計を選んだかはADRの担当なので、
設計判断が出てきたら `create-adr` に回す。

## 手順

### 1. 新規作成か更新かを判断する

ユーザーの依頼がステータス変更や内容追記であれば手順9へ進む。新規作成なら手順2へ。

### 2. PRDが必要な規模か判断する

以下のいずれかに当てはまる場合のみ作成する:

- 変更が複数のプルリクエストにまたがる
- 複数のプラットフォームやプロファイルに影響する
- 完了条件がタイトルから読み取れない

当てはまらない場合はファイルを作らず、GitHub issue（`.github/ISSUE_TEMPLATE/feature_request.yml`）
で足りると理由を述べて終了する。ユーザーがそれでも作成を指示した場合は作成する。

### 3. 出力先を確認する

```bash
ls docs/prd/template.md docs/prd/README.md
```

存在しない場合は、このリポジトリにPRDの仕組みが無い。ディレクトリ一式を新規作成してよいか
`AskUserQuestion` で確認し、了承されたら dotfiles の `docs/prd/` と同じ構成
（`README.md`, `template.md`）を作ってから続行する。

### 4. 次の番号を採番する

```bash
LAST=$(ls docs/prd | grep -oE '^[0-9]{4}' | sort -n | tail -1)
NUMBER=$(printf '%04d' $((10#${LAST:-0} + 1)))
```

ADRとは独立した連番。欠番は詰めず、再利用しない。

### 5. タイトルとファイル名を決める

タイトルは達成したい状態を表す（例: `Minimal profile for machine recovery`）。
日本語で与えられた場合は自分で英訳する。

```bash
SLUG=$(printf '%s' "$ENGLISH_TITLE" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g; s/-{2,}/-/g')
FILE="docs/prd/${NUMBER}-${SLUG}.md"
```

### 6. テンプレートを埋める

`docs/prd/template.md` をコピーして各セクションを埋める。本文は英語で書く
（このリポジトリのドキュメントは英語で統一されている）。

- Status: 新規作成時は常に `Draft`。承認状態は無い
- Date: `date +%F` の値
- ADRs: 既に関連ADRがあればリンク、無ければ `none`

`Problem` / `Goals` / `Non-goals` が会話の文脈から埋まらない場合は `AskUserQuestion` で聞く。
この3つは推測で埋めてはいけない。`Requirements` 以降は文脈から下書きしてよいが、
確信の無い箇所は `Open questions` に落とす。

### 7. 品質チェック

書き終えたら自分で確認し、満たさないものは書き直す:

- `Problem` に解決策が混ざっていないか。今の何が壊れているか、放置するコストが書かれているか
- `Goals` が検証可能か。「速くする」のような測れない記述になっていないか
- `Non-goals` が空でないか。境界を書かないPRDは実装中に膨らむ
- `Requirements` が番号付きで、プルリクエストから参照できる粒度か
- 実装に着手する段階なら、`Open questions` が空になっているか

### 8. 索引を更新する

`docs/prd/README.md` の `## Index` に1行追加する。最新が最後に来る順で並べる。

```markdown
- [NNNN — Title](./NNNN-slug.md) — Draft
```

`_No documents yet._` というプレースホルダがある場合は、その行を置き換える。

### 9. 既存PRDを更新する場合

ステータス遷移は `Draft` → `Shipped`、または途中で `Dropped`。承認状態は無い。

- `Shipped` にする: `Status` 行と `ADRs` 行を更新する。本文（Problem以降）は書き換えない。
  計画と実際の差分を後から比較できることがPRDの価値なので、後知恵で辻褄を合わせない
- `Dropped` にする: `Status` 行を変更し、`Open questions` に中止理由を1行残す

いずれの場合も `docs/prd/README.md` の索引に書かれたステータスも合わせて更新する。

### 10. 設計判断が出てきた場合

PRDを書く過程で「どの方式を選ぶか」の議論になったら、その結論はPRDに書かず
`create-adr` スキルでADRを作成し、PRDの `ADRs` 行からリンクする。

### 11. 報告する

作成または更新したファイルパスと Status を1行で報告する。
コミットはユーザーの明示的な指示があるまで行わない。

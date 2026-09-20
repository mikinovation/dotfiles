---
name: create-adr
description: アーキテクチャ決定記録（ADR）を docs/adr/ に作成するスキル。次の連番を採番し、テンプレートを埋め、索引を更新する。決定を覆す場合のsupersede処理も行う。「ADRを書いて」「決定記録を作成」「create adr」「/create-adr」「この決定を記録して」などで使用。
---

# create-adr: ADR作成スキル

`docs/adr/` に決定記録を1ファイル追加する。受理後のADRは書き換えない前提なので、
書く前に「記録する価値があるか」を判断すること。

## 手順

### 1. 記録すべきか判断する

以下のいずれかに当てはまる場合のみ作成する:

- 明らかな代替案を却下した
- あるコストを別のコストと交換した
- 制約を知らない人間が見たら間違いに見える選択をした

当てはまらない場合はファイルを作らず、「コードから自明なのでADRは不要」と理由を述べて終了する。
ユーザーがそれでも作成を指示した場合は作成する。

### 2. 出力先を確認する

`docs/adr/template.md` と `docs/adr/README.md` の存在を確認する。

```bash
ls docs/adr/template.md docs/adr/README.md
```

存在しない場合は、このリポジトリにADRの仕組みが無い。ディレクトリ一式を新規作成してよいか
`AskUserQuestion` で確認し、了承されたら dotfiles の `docs/adr/` と同じ構成
（`README.md`, `template.md`）を作ってから続行する。

### 3. 次の番号を採番する

```bash
LAST=$(ls docs/adr | grep -oE '^[0-9]{4}' | sort -n | tail -1)
NUMBER=$(printf '%04d' $((10#${LAST:-0} + 1)))
```

欠番は詰めない。Dropped や Superseded になった番号も再利用しない。

### 4. タイトルとファイル名を決める

タイトルは決定内容を名詞句で表す（例: `DOTFILES_PROFILE is required`）。
日本語で与えられた場合は自分で英訳する。ファイル名は英題をkebab-caseに正規化する:

```bash
SLUG=$(printf '%s' "$ENGLISH_TITLE" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g; s/-{2,}/-/g')
FILE="docs/adr/${NUMBER}-${SLUG}.md"
```

### 5. テンプレートを埋める

`docs/adr/template.md` をコピーして各セクションを埋める。本文は英語で書く
（このリポジトリのドキュメントは英語で統一されている）。

- Status: 常に `Accepted`。PRのマージが受理にあたるため、中間状態は使わない
- Date: `date +%F` の値
- PRD: 発端となったPRDがあれば `[NNNN — Title](../prd/NNNN-slug.md)`、無ければ `none`

内容は会話の文脈から埋める。文脈に無い情報は捏造せず `AskUserQuestion` で聞く。
特に `Alternatives considered` が埋まらない場合は、検討した代替案を必ず質問すること。

### 6. 品質チェック

書き終えたら自分で確認し、満たさないものは書き直す:

- `Context` が制約を述べているか。経緯の物語になっていないか
- `Decision` が現在形で、反論可能な程度に具体的か
- `Consequences` に欠点が含まれているか。利点だけの記録は後から価値が無い
- `Alternatives considered` が空でないか。空なら手順1に戻り、記録自体が不要ではないか再考する

### 7. 索引を更新する

`docs/adr/README.md` の `## Index` に1行追加する。最新が最後に来る順で並べる。

```markdown
- [NNNN — Title](./NNNN-slug.md)
```

`_No records yet._` というプレースホルダがある場合は、その行を置き換える。

### 8. PRD側の相互参照を更新する

発端となったPRDがある場合、そのPRDの `ADRs:` 行に今回のADRへのリンクを追加する。

### 9. 既存の決定を覆す場合

古いファイルは本文を書き換えない。次の2つだけ行う:

1. 新しい番号でADRを作成し、`Context` に「NNNN を見直す理由」を書く
2. 古いファイルの `Status` 行のみを `Superseded by [NNNN](./NNNN-slug.md)` に変更する

### 10. 報告する

作成したファイルパスと Status を1行で報告する。コミットはユーザーの明示的な指示があるまで行わない。

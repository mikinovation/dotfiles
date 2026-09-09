# Decision パターン — TypeScript 版

[.claude/rules/decision-pattern.md](../../.claude/rules/decision-pattern.md) (v0.1.1) の
`ReplyCreate`（コメント返信の作成可否）の例を TypeScript に写したもの。

- [`reply-create.ts`](./reply-create.ts) — domain。事実 / 状態 / sum type / コンストラクタ
- [`interpreter.ts`](./interpreter.ts) — interpreter。取得と適用だけを行うループ

```
NeedParentComment → NeedArticle ─ 投稿者が著者本人 ─────→ NeedThreadAuthorIds → Decided
                                └ 他人 → NeedBlock ────┘
```

## Go 規約との対応

| 規約 (Go) | TypeScript での実現 |
|---|---|
| `//sumtype:decl` + marker method | `kind` リテラルによる判別可能ユニオン |
| `go-check-sumtype` の網羅チェック | `default: assertNever(decision)` — 型検査で落ちる |
| `-default-signifies-exhaustive=false` | 不要。`assertNever` は `default` があっても効く |
| `exhaustruct`（事実の渡し忘れ検出） | 構造的型付け。プロパティ不足はそのまま型エラー |
| 事実 struct の embed（フィールド昇格） | 交差型。`facts.articleId` と平らに読め、遷移は `{ ...this.facts, 追加分 }` の 1 行 |
| 状態を値で返す（ポインタ不可） | N/A。`kind` で判別するので参照/値の区別は影響しない |
| 状態を interface と同じパッケージに置く | 状態とユニオンを同じモジュールに置く |
| `Option[T]`（確定した結果としての不在） | `T \| null`。「未取得」には使わない |
| `Err error` | `ReplyCreateError` 判別可能ユニオン。呼び出し側でも網羅できる |
| 事実の型は非公開 | モジュールから `export` しない |

## 網羅チェックが効くことの確認

状態を足してユニオンに載せ、interpreter の `case` を書き忘れた場合:

```
interpreter.ts(73,28): error TS2345:
  Argument of type 'ReplyCreateNeedMuted' is not assignable to parameter of type 'never'.
```

事実の struct を渡し忘れた場合（`{ ...this.facts }` の書き漏らし）:

```
reply-create.ts(113,39): error TS2345:
  Type '{ articleId: ArticleId; parentAuthorId: UserId; }' is missing the following
  properties from type 'ReplyCreateFactsInput': posterId, parentCommentId, body
```

Go 版では前者が `go-check-sumtype`、後者が `exhaustruct` という別々の lint だが、
TypeScript ではどちらも `tsc --strict` だけで検出できる。

## 型検査

```bash
tsc --strict --noEmit --target es2022 --module nodenext --moduleResolution nodenext \
  --exactOptionalPropertyTypes --noUncheckedIndexedAccess \
  docs/decision-pattern-ts/*.ts
```

## TypeScript 固有の注意

- **状態は class にする。** plain object + 関数テーブルでも書けるが、`decide` を状態に
  持たせないと「状態から次の状態への辺」が型からたどれなくなる。規約が遷移メソッド名を
  `Decide` に固定しているのと同じ理由で、`decide` に固定する。
- **`kind` は `as const` を付ける。** 付けないと `string` に広がり、判別可能ユニオンとして
  narrowing されず `assertNever` が機能しない。
- **`readonly` を付ける。** Go の値レシーバは状態のコピーを渡すので前の状態は壊れない。
  TS は参照なので、`readonly` を付けないと `decide` の外から事実を書き換えられる。
- **交差型は「ここまでの履歴」を型にしたもの。** 別経路からその状態に到達するなら
  組み立てられないので、合流点で前段の事実を落として鎖を始め直す。

// Decision パターン (.claude/rules/decision-pattern.md v0.1.1) の TypeScript 版。
//
// 判定対象: コメント返信の作成可否 (ReplyCreate)。
//
//   NeedParentComment → NeedArticle ─ 投稿者が著者本人 ─────→ NeedThreadAuthorIds → Decided
//                                   └ 他人 → NeedBlock ────┘
//
// domain 層。副作用を持たず、取得は一切行わない。

declare const brand: unique symbol;
type Brand<T, B extends string> = T & { readonly [brand]: B };

export type UserId = Brand<string, "UserId">;
export type ArticleId = Brand<string, "ArticleId">;
export type CommentId = Brand<string, "CommentId">;

export type Article = {
  readonly id: ArticleId;
  readonly authorId: UserId;
  readonly visibility: "public" | "unlisted" | "private";
};

export type Comment = {
  readonly id: CommentId;
  readonly articleId: ArticleId;
  readonly authorId: UserId;
  readonly deletedAt: Date | null;
};

export type Block = {
  readonly blockerId: UserId;
  readonly blockedId: UserId;
};

// ---------------------------------------------------------------------------
// 判定の結果
// ---------------------------------------------------------------------------

export type Mutation =
  | {
      readonly type: "CreateReply";
      readonly articleId: ArticleId;
      readonly parentCommentId: CommentId;
      readonly authorId: UserId;
      readonly body: string;
      readonly createdAt: Date;
    }
  | {
      readonly type: "NotifyReply";
      readonly userId: UserId;
      readonly parentCommentId: CommentId;
      readonly createdAt: Date;
    };

// Go 版の `Err error` に相当。TS では判別可能ユニオンにして、
// interpreter 側でも網羅チェックが効く形にする。
export type ReplyCreateError =
  | { readonly code: "ParentCommentDeleted"; readonly parentCommentId: CommentId }
  | { readonly code: "ArticleNotPublic"; readonly articleId: ArticleId }
  | { readonly code: "BlockedByAuthor"; readonly authorId: UserId }
  | { readonly code: "ThreadParticipantLimitExceeded"; readonly limit: number };

// ---------------------------------------------------------------------------
// 事実 (facts)
//
// 1 回の取得（または 1 回の判定）が確定させる単位で型に分ける。
// Go の embed による昇格は TS に無いので交差型で代用する。
// 交差型なら `facts.articleId` と平らに読め、遷移時のコピーも
// `{ ...this.facts, 追加分 }` の 1 行で済む。
// 型は export しない（Go 版の「型は非公開、フィールドは公開」に対応）。
// ---------------------------------------------------------------------------

/** 入力で確定する事実。 */
type ReplyCreateFactsInput = {
  readonly posterId: UserId;
  readonly parentCommentId: CommentId;
  readonly body: string;
};

/** 親コメント取得で確定する事実。前段の事実を含める。 */
type ReplyCreateFactsParentComment = ReplyCreateFactsInput & {
  readonly articleId: ArticleId;
  readonly parentAuthorId: UserId;
};

/** Article 取得で確定する事実。前段の事実を含める。 */
type ReplyCreateFactsArticle = ReplyCreateFactsParentComment & {
  readonly articleAuthorId: UserId;
};

// ---------------------------------------------------------------------------
// 状態
//
// Go の marker method + //sumtype:decl の役割は、`kind` リテラルによる
// 判別可能ユニオンと assertNever が担う（lint ではなく型検査で落ちる）。
// ---------------------------------------------------------------------------

export const MAX_THREAD_PARTICIPANTS = 50;

/** 開始状態。取得キーは facts.parentCommentId。 */
export class ReplyCreateNeedParentComment {
  readonly kind = "ReplyCreateNeedParentComment" as const;

  constructor(readonly facts: ReplyCreateFactsInput) {}

  decide(parentComment: Comment): ReplyCreateDecision {
    if (parentComment.deletedAt !== null) {
      return new ReplyCreateFailed({
        code: "ParentCommentDeleted",
        parentCommentId: parentComment.id,
      });
    }
    return new ReplyCreateNeedArticle({
      ...this.facts,
      articleId: parentComment.articleId,
      parentAuthorId: parentComment.authorId,
    });
  }
}

/** 取得キーは確定済みの facts.articleId なので、状態に重複して持たない。 */
export class ReplyCreateNeedArticle {
  readonly kind = "ReplyCreateNeedArticle" as const;

  constructor(readonly facts: ReplyCreateFactsParentComment) {}

  decide(article: Article): ReplyCreateDecision {
    if (article.visibility !== "public") {
      return new ReplyCreateFailed({ code: "ArticleNotPublic", articleId: article.id });
    }

    const facts: ReplyCreateFactsArticle = {
      ...this.facts,
      articleAuthorId: article.authorId,
    };

    // 投稿者が著者本人ならブロック関係の確認は不要。
    if (facts.posterId === facts.articleAuthorId) {
      return new ReplyCreateNeedThreadAuthorIds(facts);
    }
    return new ReplyCreateNeedBlock(facts);
  }
}

/** 取得キーは facts.articleAuthorId（ブロック元）と facts.posterId（ブロック先）。 */
export class ReplyCreateNeedBlock {
  readonly kind = "ReplyCreateNeedBlock" as const;

  constructor(readonly facts: ReplyCreateFactsArticle) {}

  decide(block: Block | null): ReplyCreateDecision {
    if (block !== null) {
      return new ReplyCreateFailed({ code: "BlockedByAuthor", authorId: block.blockerId });
    }
    // block はその場の判定に使って捨てる。事実を増やさないので、
    // 著者本人の経路と同じ事実集合のまま合流できる。
    return new ReplyCreateNeedThreadAuthorIds(this.facts);
  }
}

/** 取得キーは facts.parentCommentId（スレッドの根）。 */
export class ReplyCreateNeedThreadAuthorIds {
  readonly kind = "ReplyCreateNeedThreadAuthorIds" as const;

  constructor(readonly facts: ReplyCreateFactsArticle) {}

  decide(threadAuthorIds: readonly UserId[], now: Date): ReplyCreateDecision {
    if (threadAuthorIds.length >= MAX_THREAD_PARTICIPANTS) {
      return new ReplyCreateFailed({
        code: "ThreadParticipantLimitExceeded",
        limit: MAX_THREAD_PARTICIPANTS,
      });
    }

    const { posterId, parentCommentId, articleId, body } = this.facts;
    const targets = [...new Set(threadAuthorIds)].filter((id) => id !== posterId);

    return new ReplyCreateDecided([
      { type: "CreateReply", articleId, parentCommentId, authorId: posterId, body, createdAt: now },
      ...targets.map(
        (userId) =>
          ({ type: "NotifyReply", userId, parentCommentId, createdAt: now }) as const,
      ),
    ]);
  }
}

/** 終了状態。判定の結果そのものを持つ。 */
export class ReplyCreateDecided {
  readonly kind = "ReplyCreateDecided" as const;

  constructor(readonly mutations: readonly Mutation[]) {}
}

/** 失敗状態。 */
export class ReplyCreateFailed {
  readonly kind = "ReplyCreateFailed" as const;

  constructor(readonly error: ReplyCreateError) {}
}

/**
 * sum type。状態を足したらここに 1 行足す。足し忘れると interpreter の
 * assertNever が型エラーになる（Go の go-check-sumtype 相当）。
 * 状態はこのユニオンと同じモジュールに置く。
 */
export type ReplyCreateDecision =
  | ReplyCreateDecided
  | ReplyCreateFailed
  | ReplyCreateNeedParentComment
  | ReplyCreateNeedArticle
  | ReplyCreateNeedBlock
  | ReplyCreateNeedThreadAuthorIds;

/** コンストラクタ。開始状態を隠す唯一の入口。 */
export function newReplyCreateDecision(input: {
  readonly posterId: UserId;
  readonly parentCommentId: CommentId;
  readonly body: string;
}): ReplyCreateDecision {
  return new ReplyCreateNeedParentComment(input);
}

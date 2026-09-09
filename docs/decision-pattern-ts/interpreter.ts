// interpreter 層。取得と適用だけを行い、判断は一切持たない。

import {
  newReplyCreateDecision,
  type Article,
  type ArticleId,
  type Block,
  type Comment,
  type CommentId,
  type Mutation,
  type ReplyCreateError,
  type UserId,
} from "./reply-create.js";

export interface ReplyCreateRepository {
  getComment(id: CommentId): Promise<Comment>;
  getArticle(id: ArticleId): Promise<Article>;
  /** 確定した結果として「ブロックが無い」を null で表す。「未取得」には使わない。 */
  findBlock(blockerId: UserId, blockedId: UserId): Promise<Block | null>;
  listThreadAuthorIds(rootCommentId: CommentId): Promise<readonly UserId[]>;
  apply(mutations: readonly Mutation[]): Promise<void>;
}

export type ReplyCreateResult =
  | { readonly ok: true }
  | { readonly ok: false; readonly error: ReplyCreateError };

/**
 * 状態が 1 段で終わる Decision でも同じループで書く。段が増えても形を変えずに済む。
 * now はループの前で 1 回だけ取る（段ごとに基準時刻がずれないように）。
 */
export async function runReplyCreate(
  repo: ReplyCreateRepository,
  input: { readonly posterId: UserId; readonly parentCommentId: CommentId; readonly body: string },
  now: Date = new Date(),
): Promise<ReplyCreateResult> {
  let decision = newReplyCreateDecision(input);

  for (;;) {
    switch (decision.kind) {
      case "ReplyCreateDecided": {
        await repo.apply(decision.mutations);
        return { ok: true };
      }
      case "ReplyCreateFailed": {
        return { ok: false, error: decision.error };
      }
      case "ReplyCreateNeedParentComment": {
        const parentComment = await repo.getComment(decision.facts.parentCommentId);
        decision = decision.decide(parentComment);
        break;
      }
      case "ReplyCreateNeedArticle": {
        const article = await repo.getArticle(decision.facts.articleId);
        decision = decision.decide(article);
        break;
      }
      case "ReplyCreateNeedBlock": {
        const block = await repo.findBlock(
          decision.facts.articleAuthorId,
          decision.facts.posterId,
        );
        decision = decision.decide(block);
        break;
      }
      case "ReplyCreateNeedThreadAuthorIds": {
        const authorIds = await repo.listThreadAuthorIds(decision.facts.parentCommentId);
        decision = decision.decide(authorIds, now);
        break;
      }
      default:
        // case が漏れるとここで型エラーになる。実行時は無限ループを避ける保険。
        return assertNever(decision);
    }
  }
}

function assertNever(x: never): never {
  throw new Error(`unknown decision: ${JSON.stringify(x)}`);
}

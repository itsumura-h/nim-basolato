import basolato/view
import ./feed_article_component_model

proc feedArticleFavoriteButton*(
  articleId: string,
  popularCount: int,
  isLoginUserLiked: bool,
  csrfToken: CsrfToken,
): Component =
  tmpl"""
    <span id="feed-favorite-action-$(articleId)">
      <form action="/article/$(articleId)/favorite/compact" method="post" style="display:inline">
        $(csrfToken)
        <button class="btn btn-outline-primary btn-sm pull-xs-right $if isLoginUserLiked{active}">
          <i class="ion-heart"></i> $(popularCount)
        </button>
      </form>
    </span>
  """

proc feedArticleFavoriteTurboStream*(
  articleId: string,
  popularCount: int,
  isLoginUserLiked: bool,
  csrfToken: CsrfToken,
): Component =
  tmpl"""
    <turbo-stream action="replace" target="feed-favorite-action-$(articleId)">
      <template>
        $(feedArticleFavoriteButton(articleId, popularCount, isLoginUserLiked, csrfToken))
      </template>
    </turbo-stream>
  """

proc feedArticleComponent*(model:FeedArticleComponentModel):Component =
  tmpl"""
    <div class="article-preview">
      <div class="article-meta">
        <a href="/profile/$(model.authorId)"><img src="$(model.authorImage)" /></a>
        <div class="info">
          <a href="/profile/$(model.authorId)" class="author">$(model.authorName)</a>
          <span class="date">$(model.createdAt)</span>
        </div>
        $(feedArticleFavoriteButton(model.articleId, model.popularCount, model.isLoginUserLiked, model.csrfToken))
      </div>
      <a href="/article/$(model.articleId)" class="preview-link">
        <h1>$(model.title)</h1>
        <p>$(model.description)</p>
        <span>Read more...</span>
        <ul class="tag-list">
          $for tag in model.tagList{
            <li class="tag-default tag-pill tag-outline">$(tag)</li>
          }
        </ul>
      </a>
    </div>
  """

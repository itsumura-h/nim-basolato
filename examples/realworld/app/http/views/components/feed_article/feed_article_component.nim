import basolato/view
import ./feed_article_component_model

proc feedArticleComponent*(model:FeedArticleComponentModel):Component =
  tmpl"""
    <div class="article-preview">
      <div class="article-meta">
        <a href="/profile/$(model.authorId)"><img src="$(model.authorImage)" /></a>
        <div class="info">
          <a href="/profile/$(model.authorId)" class="author">$(model.authorName)</a>
          <span class="date">$(model.createdAt)</span>
        </div>
        <button class="btn btn-outline-primary btn-sm pull-xs-right $if model.isLoginUserLiked{active}">
          <i class="ion-heart"></i> $(model.popularCount)
        </button>
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

import basolato/view
import ./article_template_model
import ../../components/article_action/article_action_component_model
import ../../components/article_action/article_action_component


proc articleTemplate*(model: ArticleTemplateModel): Component =
  let actionModel = ArticleActionComponentModel.new(
    articleId = model.articleId,
    authorId = model.author.id,
    authorName = model.author.name,
    authorImage = model.author.image,
    followerCount = model.author.followerCount,
    isFollowed = model.author.isFollowed,
    favoriteCount = model.article.favoriteCount,
    isFavorited = model.article.isFavorited,
    csrfToken = model.csrfToken,
    isAuthor = model.isAuthor
  )
  let authorActions = articleAuthorActions(actionModel)
  tmpl"""
    <div class="container">
      <h1>$(model.article.title)</h1>

      <div class="article-meta">
        <a href="/profile/$(model.author.id)"><img src="$(model.author.image)" /></a>
        <div class="info">
          <a href="/profile/$(model.author.id)" class="author">$(model.author.name)</a>
          <span class="date">$(model.article.updatedAt)</span>
        </div>
        <span id="article-follow-action-banner-$(model.articleId)">
          $(articleFollowAction(actionModel, "banner"))
        </span>
        &nbsp;&nbsp;
        <span id="article-favorite-action-banner-$(model.articleId)">
          $(articleFavoriteAction(actionModel, "banner"))
        </span>
        $(authorActions)
      </div>
    </div>
  </div>

  <div class="container page">
    <div class="row article-content">
      <div class="col-md-12">
        
        $(model.article.content |raw)
        <br>

        $if model.article.tagList.len > 0{
          <ul class="tag-list">
            $for tag in model.article.tagList{
              <li class="tag-default tag-pill tag-outline">$(tag)</li>
            }
          </ul>
        }
      </div>
    </div>

    <hr />

    <div class="article-actions">
      <div class="article-meta">
        <a href="/profile/$(model.author.id)"><img src="$(model.author.image)" /></a>
        <div class="info">
          <a href="/profile/$(model.author.id)" class="author">$(model.author.name)</a>
          <span class="date">$(model.article.updatedAt)</span>
        </div>

        <span id="article-follow-action-footer-$(model.articleId)">
          $(articleFollowAction(actionModel, "footer"))
        </span>
        &nbsp;
        <span id="article-favorite-action-footer-$(model.articleId)">
          $(articleFavoriteAction(actionModel, "footer"))
        </span>
        $(authorActions)
      </div>
    </div>

    <link rel="stylesheet" href="https://unpkg.com/prismjs@1.29.0/themes/prism-okaidia.min.css">
    <script src="https://unpkg.com/prismjs@1.29.0/components/prism-core.min.js"></script>
    <script src="https://unpkg.com/prismjs@1.29.0/plugins/autoloader/prism-autoloader.min.js"></script>
  """

import std/asyncdispatch
import basolato/view
import ../../components/feed_article/feed_article_component
import ../../components/paginator/paginator_component
import ./user_article_list_template_model


proc userArticleListTemplate*(context: Context): Future[Component] {.async.} =
  let model = await UserArticleListTemplateModel.new(context)
  tmpl"""
    <div class="articles-toggle">
      <ul class="nav nav-pills outline-active">
        <li class="nav-item">
          <a class="nav-link $if not model.isFavorite{active}" href="/profile/$(model.userId)">My Articles</a>
        </li>
        <li class="nav-item">
          <a class="nav-link $if model.isFavorite{active}" href="/profile/$(model.userId)/favorite">Favorited Articles</a>
        </li>
      </ul>
    </div>

    $for article in model.articleList{
      $(feedArticleComponent(article))
    }

    $(paginatorComponent(model.paginatorModel))
  """

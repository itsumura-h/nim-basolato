import std/asyncdispatch
import basolato/view
import ../../../../presenters/user_article_list/user_article_list_presenter
import ../../../../presenters/user_article_list/user_favorite_article_list_presenter
import ../../components/feed_article/feed_article_component
import ../../components/paginator/paginator_component


type PageType = enum
  myArticle,
  favorite


proc userArticleListTemplate*():Future[Component] {.async.} =
  let context = context()
  let pageType =
    if context.request.url.path.split("/")[^1] == "favorite":
      PageType.favorite
    else:
      PageType.myArticle

  let model =
    if pageType == PageType.myArticle:
      let presenter = UserArticleListPresenter.new()
      presenter.invoke().await
    else:
      let presenter = UserFavoriteArticleListPresenter.new()
      presenter.invoke().await

  tmpl"""
    <div class="articles-toggle">
      <ul class="nav nav-pills outline-active">
        <li class="nav-item">
          <a class="nav-link $if pageType == PageType.myArticle{active}" href="/profile/$(model.userId)">My Articles</a>
        </li>
        <li class="nav-item">
          <a class="nav-link $if pageType == PageType.favorite{active}" href="/profile/$(model.userId)/favorite">Favorited Articles</a>
        </li>
      </ul>
    </div>

    $for article in model.articleList{
      $(feedArticleComponent(article))
    }

    $(paginatorComponent(model.paginatorModel))
  """

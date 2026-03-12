# import std/json
import basolato/view
import ./article_preview_view_model
import ../favorite_button/favorite_button_view
import ./feed_navigation/feed_navigation_view
import ./paginator/paginator_view


proc impl(viewModel:ArticlePreviewViewModel):Component =
  tmpl"""
    $(feedNavigationView(viewModel.feedNavbarItems))

    <div id="feed-article-preview" hx-swap-oob="true">
      $for article in viewModel.articles{
        <div class="article-preview">
          <div class="article-meta">
            <a href="/users/$(article.user.id)"
              hx-push-url="/users/$(article.user.id)"
              hx-get="/island/users/$(article.user.id)"
              hx-target="#app-body"
            >
              <img src="$(article.user.image)" />
            </a>

            <div class="info">
              <a href="/users/$(article.user.id)"
                hx-push-url="/users/$(article.user.id)"
                hx-get="/island/users/$(article.user.id)"
                hx-target="#app-body"
                class="author"
              >
                $(article.user.name)
              </a>
              <span class="date">$(article.createdAt)</span>
            </div>

            $(favoriteButtonView(article.favoriteButtonViewModel))

          </div>
          <a href="/articles/$(article.id)"
            hx-push-url="/articles/$(article.id)"
            hx-get="/island/articles/$(article.id)"
            hx-target="#app-body"
            class="preview-link"
          >
            <h1>$(article.title)</h1>
            <p>$(article.description)</p>

            <div class="m-t-1">
              <span>Read more...</span>

              <ul class="tag-list">
                $for tag in article.tags{
                  <li class="tag-default tag-pill tag-outline">$(tag.name)</li>
                }
              </ul>
            </div>
          </a>
        </div>
      }
        
      $if viewModel.articles.len() == 0{
        <div class="article-preview">
          <div class="alert alert-warning" role="alert">
            No articles are here... yet.
          </div>
        </div>
      }
    </div>

    $(paginatorView(viewModel.paginator))
  """

proc articlePreviewView*(viewModel:ArticlePreviewViewModel):Component =
  return impl(viewModel)

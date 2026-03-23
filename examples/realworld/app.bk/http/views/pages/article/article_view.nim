import std/options
import basolato/view
import ./article_view_model
import ../../layouts/app/app_view_model
import ../../layouts/app/app_view
import ./follow_button/follow_button_view
import ./favorite_button/favorite_button_in_article_view
import ./edit_button/edit_button_view
import ./delete_button/delete_button_view


proc impl(viewModel:ArticleViewModel):Component =
  let style = styleTmpl(Css, """
    <style>
      .inline-flex {
        display: inline-flex;
      }
    </style>
  """)

  tmpl"""
    <div class="article-page">

      <div class="banner">
        <div class="container">

          <h1>$(viewModel.article.title)</h1>

          <div class="article-meta">
            <a href="profile.html"><img src="$(viewModel.user.image)" /></a>
            <div class="info">
              <a href="/users/$(viewModel.user.id)"
                hx-push-url="/users/$(viewModel.user.id)"
                hx-get="/island/users/$(viewModel.user.id)"
                hx-target="#app-body"
                class="author"
              >
                $(viewModel.user.name)
              </a>
              <span class="date">$(viewModel.article.createdAt)</span>
            </div>

            <!-- if author -->
            $if viewModel.isAuthor{
              <!-- edit-button -->
              $( editButtonView(viewModel.editButtonViewModel.get) )
              <!-- delete-button -->
              $( deleteButtonView(viewModel.deleteButtonViewModel.get) )
            }$else{
              <div class="$(style.element("inline-flex"))">
                <!-- follow button -->
                $( followButtonView(viewModel.followButtonViewModel.get) )
                <!-- favorite button -->
                $( favoriteButtonInArticleView(viewModel.favoriteButtonViewModel.get) )
              </div>
            }
          </div>

        </div>
      </div>

      <div class="container page">

        <div class="row post-content">
          <div class="col-md-12">
            $(viewModel.article.body)  
          </div>
          <div class="col-md-12 m-t-2">
            <ul class="tag-list">
              $for tag in viewModel.article.tags{
                <li class="tag-default tag-pill tag-outline">$(tag.tagName)</li>
              }
            </ul>
          </div>
        </div>

        <hr />

        <div class="article-actions">
          <div class="article-meta">
            <a href="profile.html"><img src="$(viewModel.user.image)" /></a>
            <div class="info">
              <a href="/users/$(viewModel.user.id)"
                hx-push-url="/users/$(viewModel.user.id)"
                hx-get="/island/users/$(viewModel.user.id)"
                hx-target="#app-body"
                class="author"
              >
                $(viewModel.user.name)
              </a>
              <span class="date">$(viewModel.article.createdAt)</span>
            </div>

            <!-- if author -->
            $if viewModel.isAuthor{
              $( editButtonView(viewModel.editButtonViewModel.get) )
              <!-- delete-button -->
              $( deleteButtonView(viewModel.deleteButtonViewModel.get) )
            }$else{
              <div class="$(style.element("inline-flex"))">
                <!-- follow button -->
                $(followButtonView(viewModel.followButtonViewModel.get))
                <!-- favorite button -->
                $(favoriteButtonInArticleView(viewModel.favoriteButtonViewModel.get))
              </div>
            }
          </div>
        </div>

        <div class="row">
          <div class="col-xs-12 col-md-8 offset-md-2" hx-get="/island/articles/$(viewModel.article.id)/comments" hx-trigger="load"></div>
        </div>

      </div>

    </div>
    $(style)
  """

proc islandArticleShowView*(viewModel:ArticleViewModel):Component =
  return impl(viewModel)

proc articleShowPageView*(appViewModel:AppViewModel, viewModel:ArticleViewModel):Component =
  return appView(appViewModel, impl(viewModel))

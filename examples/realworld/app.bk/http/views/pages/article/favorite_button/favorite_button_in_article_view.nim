import basolato/view
import ./favorite_button_in_article_view_model


proc favoriteButtonInArticleView*(viewModel: FavoriteButtonInArticleViewModel): Component =
  tmpl"""
    <form
      hx-post="/island/articles/$(viewModel.articleId)/favorite"
      hx-swap="outerHTML"
      class="favorite-button"
    >
      $(csrfToken())
      <button class="btn btn-outline-primary btn-sm pull-xs-right $if viewModel.isFavorited{active}">
        <i class="ion-heart"></i>
        $if viewModel.isFavorited{
          Unfavorite Post
        }$else{
          Favorite Post
        }
        $(viewModel.count)
      </button>
    </form>
  """

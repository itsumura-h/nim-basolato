import basolato/view
import ./favorite_button_view_model


proc favoriteButtonView*(viewModel: FavoriteButtonViewModel): Component =
  tmpl"""
    <form
      hx-post="/island/users/articles/$(viewModel.articleId)/favorite"

      $if viewModel.willDelete{
        hx-swap="delete"
        hx-target="closest .article-preview"
      }$else{
        hx-swap="outerHTML"
      }
    >
      $context.csrfToken()
      <button class="btn btn-outline-primary btn-sm pull-xs-right $if viewModel.isFavorited{active}">
        <i class="ion-heart"></i>
        $(viewModel.count)
      </button>
    </form>
  """

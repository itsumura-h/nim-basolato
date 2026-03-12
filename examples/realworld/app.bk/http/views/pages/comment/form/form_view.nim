import basolato/view
import ./form_view_model


proc formView*(viewModel:FormViewModel, oobSwap:bool):Component =
  tmpl"""
    <div id="form-message"></div>

    <form id="article-comment-form" class="card comment-form"
      hx-post="/island/articles/$(viewModel.articleId)/comments" 
      hx-target="#article-comments-wrapper" hx-swap="afterbegin show:top"
      $if oobSwap{
        hx-swap-oob="true"
      }
    >
      <div class="card-block">
        <textarea class="form-control" placeholder="Write a comment..." rows="3" name="comment"></textarea>
      </div>
      <div class="card-footer">
        <img src="$(viewModel.userImage)" class="comment-author-img" />
        <button class="btn btn-sm btn-primary">
          Post Comment
        </button>
      </div>
    </form>
  """

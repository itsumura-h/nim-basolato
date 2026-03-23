import basolato/view
import ./card_view_model


proc cardView*(viewModel:CardViewModel):Component =
  tmpl"""
    <div class="card">
      <div class="card-block">
        <p class="card-text">
          $(viewModel.body)
        </p>
      </div>
      <div class="card-footer">
        <a
          href="/users/$(viewModel.userId)"
          hx-push-url="/users/$(viewModel.userId)"
          hx-get="/island/users/$(viewModel.userId)"
          hx-target="#app-body"
          class="comment-author"
        >
          <img src="$(viewModel.userImage)" class="comment-author-img" />
        </a>
        &nbsp;
        <a
          href="/users/$(viewModel.userId)"
          hx-push-url="/users/$(viewModel.userId)"
          hx-get="/island/users/$(viewModel.userId)"
          hx-target="#app-body"
          class="comment-author"
        >
          $(viewModel.userName)
        </a>
        <span class="date-posted">$(viewModel.createdAt)</span>
      </div>
    </div>
  """

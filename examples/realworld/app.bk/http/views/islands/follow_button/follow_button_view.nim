import basolato/view
import ./follow_button_view_model

proc followButtonView*(viewModel:FollowButtonViewModel):Component =
  tmpl"""
    <form
      hx-post="/island/users/$(viewModel.userId)/follow"
      hx-swap="outerHTML"
    >
      $context.csrfToken()
      <button
        class="btn btn-sm btn-outline-secondary follow-button action-btn"
        type="submit"
      >
        $if viewModel.isFollowed{
          <i class="ion-minus-round"></i>
          Unfollow
        }$else{
          <i class="ion-plus-round"></i>
          Follow
        }
        $(viewModel.userName)
        <span class="counter">($(viewModel.followerCount))</span>
      </button>
    </form>
  """

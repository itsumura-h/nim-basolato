import basolato/view
import ./paginator_view_model


proc paginatorView*(viewModel:PaginatorViewModel):Component =
  tmpl"""
    $if viewModel.hasPages{
      <nav id="feed-pagination" hx-swap-oob="true">
        <ul class="pagination">
        $for i in 1..viewModel.lastPage{
          <li class="page-item $if viewModel.current == i { active }">
            <a class="page-link"
              href="$(viewModel.hxGetUrl)?page=$(i)"
              hx-push-url=""
              hx-get="$(viewModel.hxGetUrl)?page=$(i)"
            >$(i)</a>
          </li>
        }
        </ul>
      </nav>
    }$else{
      <nav id="feed-pagination" hx-swap-oob="true"></nav>
    }
  """

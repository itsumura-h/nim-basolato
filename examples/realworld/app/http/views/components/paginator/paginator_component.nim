import basolato/view
import ./paginator_component_model

proc paginatorComponent*(model: PaginatorComponentModel): Component =
  let context = context()
  let path = context.request.url.path

  tmpl"""
    $if model.hasPages{
      <ul class="pagination">
        $for i in 1..model.lastPage{
          <li class="page-item $if model.currentPage == i{active}">
            <a class="page-link" href="$(path)?page=$(i)">$(i)</a>
          </li>
        }
      </ul>
    }
  """

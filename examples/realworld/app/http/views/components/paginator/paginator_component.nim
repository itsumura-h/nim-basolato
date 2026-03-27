import basolato/view
import ./paginator_component_model

proc paginatorComponent*(model: PaginatorComponentModel): Component =
  tmpl"""
    $if model.hasPages{
      <ul class="pagination">
        $for i in 1..model.lastPage{
          <li class="page-item $if model.currentPage == i{active}">
            <a class="page-link" href="$(model.path)?page=$(i)">$(i)</a>
          </li>
        }
      </ul>
    }
  """

import json, asyncdispatch
import ../../../../../../../../../../src/basolato/view
import ./task_view_model


proc taskView*(viewModel:TaskViewModel):Component =
  let style = styleTmpl(Css, """
    <style>
      .columns {
        max-width: 100%;
        margin: auto;
      }
      .task {
        margin: 12px 0px;
      }
      .form {
        padding: 0;
      }
      .button {
        width: 100%;
        height: 100%;
      }
    </style>
  """)

  tmpli html"""
    $(style)
    <article class="bulma-card $(style.element("task"))">
      <div class="bulma-card-header bulma-columns $(style.element("columns"))">
        $if viewModel.isDisplayUp {
          <form method="POST" action="/todo/change-sort" class="bulma-column $(style.element("form"))">
            $(csrfToken())
            <button class="bulma-button $(style.element("button"))">
              <span class="bulma-icon"><i class="fas fa-arrow-up"></i></span>
            </button>
            <input type="hidden" name="id" value="$(viewModel.id)">
            <input type="hidden" name="next_id" value="$(viewModel.upId)">
          </form>
        }
        $if viewModel.isDisplayDown {
          <form method="POST" action="/todo/change-sort" class="bulma-column $(style.element("form"))">
            $(csrfToken())
            <button class="bulma-button $(style.element("button"))">
              <span class="bulma-icon"><i class="fas fa-arrow-down"></i></span>
            </button>
            <input type="hidden" name="id" value="$(viewModel.id)">
            <input type="hidden" name="next_id" value="$(viewModel.downId)">
          </form>
        }
      </div>
      <div class="bulma-card-content">
        <div class="bulma-content">
          <p><a href="/todo/$(viewModel.id)">$(viewModel.title)</a></p>
          <p>created: $(viewModel.createdName)</p>
          <p>assign: $(viewModel.assignName)</p>
          <p>start: $(viewModel.startOn)</p>
          <p>end_on: $(viewModel.endOn)</p>
        </div>
      </div>
      <footer class="bulma-card-footer">
        $if viewModel.statusId > 1 {
          <form method="POST" action="/todo/change-status" class="bulma-card-footer-item $(style.element("form"))">
            $(csrfToken())
            <input type="hidden" name="id" value="$(viewModel.id)">
            <button class="bulma-button $(style.element("button"))">
              <span class="bulma-icon"><i class="fas fa-arrow-left"></i></span>
            </button>
          </form>
        }
        $if viewModel.statusId < 3 {
          <form method="POST" action="/todo/change-status" class="bulma-card-footer-item $(style.element("form"))">
            $(csrfToken())
            <input type="hidden" name="id" value="$(viewModel.id)">
            <button class="bulma-button $(style.element("button"))">
              <span class="bulma-icon"><i class="fas fa-arrow-right"></i></span>
            </button>
          </form>
        }
      </footer>
    </article>
  """

import json, asyncdispatch, std/enumerate
import ../../../../../../../../../src/basolato/view
import ./status_view_model
import ./task/task_view


proc statusView*(status:StatusViewModel):Component =
  let style = styleTmpl(Css, """
    <style>
      .className {
      }
    </style>
  """)

  tmpli html"""
    <div class="bulma-column">
      <div class="bulma-card">
        <div class="bulma-card-header">
          <h2 class="bulma-title is-2">$(status.name)</h2>
        </div>
        <div class="bulma-card-content">
          $for i, task in status.tasks{
            $(taskView(task))
          }
        </div>
      </div>
    </div>
  """

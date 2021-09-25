import json, std/enumerate
import ../../../../../../../src/basolato/view
import task_view


proc statusView*(status, data:JsonNode):string =
  style "css", style:"""
    <style>
      .className {
      }
    </style>
  """

  script ["idName"], script:"""
    <script>
    </script>
  """

  tmpli html"""
    <div class="column">
      <div class="card">
        <div class="card-header">
          <h2 class="title is-2">$(status["name"].get)</h2>
        </div>
        <div class="card-content">
          ${
            let statusColumn = data["transaction"][status["name"].getStr]
          }
          $for i, todo in enumerate(statusColumn){
            $(
              let upSortNum =
                if i == 0: 0
                else: statusColumn[i-1]["sort"].getInt

              let downSortNum =
                if i == statusColumn.len-1: 0
                else: statusColumn[i+1]["sort"].getInt

              taskView(
                todo,
                i > 0,
                i < statusColumn.len-1,
                upSortNum,
                downSortNum
              )
            )
          }
        </div>
      </div>
    </div>
  """

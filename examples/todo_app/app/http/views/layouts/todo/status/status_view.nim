import json, asyncdispatch, std/enumerate
import ../../../../../../../../src/basolato/view
import ./status_view_model
import ../task_view


proc statusView*(status:StatusViewModel, data:seq[JsonNode]):Future[string] {.async.} =
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
          <h2 class="title is-2">$(status.name)</h2>
        </div>
        <div class="card-content">
          $for i, todo in enumerate(data){
            $(
              let upId =
                if i == 0: ""
                else: data[i-1]["id"].getStr
              let downId =
                if i == data.len-1: ""
                else: data[i+1]["id"].getStr

              taskView(
                todo,
                i > 0,
                i < data.len-1,
                upId,
                downId,
                status.id,
              ).await
            )
          }
        </div>
      </div>
    </div>
  """

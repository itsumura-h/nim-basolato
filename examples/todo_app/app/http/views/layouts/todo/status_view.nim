import json, std/enumerate
import ../../../../../../../src/basolato/view
import task_view

proc statusView*(status, data:JsonNode):string = tmpli html"""
<div class="column">
  <div class="card">
    <div class="card-header">
      <h2 class="title is-2">$(status["name"].get)</h2>
    </div>
    <div class="card-content">
      $for i, todo in enumerate(data["transaction"][status["name"].getStr]){
        $(taskView(
          todo,
          i > 0,
          i < data["transaction"][status["name"].getStr].len-1
        ))
      }
    </div>
  </div>
</div>
"""

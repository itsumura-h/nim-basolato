import json
import ../../../../../src/basolato/view
import ../../layouts/application_view
import ../../layouts/todo/header_view
import ../../layouts/todo/input_view
import ../../layouts/todo/errors_view
import ../../layouts/todo/table_view

let style = block:
  var css = newCss()
  css

proc impl(auth:Auth, todos:seq[JsonNode], params, errors:JsonNode):string = tmpli html"""
<div class="section">
  $(headerView(auth.get("name")))
  $(inputView(params, errors))
  $(errorsView(auth))
  $(tableView(todos))
</div>
"""

proc indexView*(auth:Auth, todos=newSeq[JsonNode](), params=newJObject(), errors=newJObject()):string =
  let title = "Todo App"
  return applicationView(title, impl(auth, todos, params, errors))

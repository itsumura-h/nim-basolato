import json, asyncdispatch
import ../../../../../../../src/basolato/view
import ../../layouts/application_view
import ../../layouts/todo/header_view
import ../../layouts/todo/input_view
import ../../layouts/todo/errors_view
import ../../layouts/todo/table_view

let style = block:
  var css = newCss()
  css

proc impl(auth:Auth, todos:seq[JsonNode], params, errors:JsonNode):Future[string] {.async.} = tmpli html"""
<section class="section">
  <div class="container is-max-desktop">
    $(headerView(await auth.get("name")))
    $(inputView(params, errors))
    $(await errorsView(auth))
    $(tableView(todos))
  </div>
</div>
"""

proc indexView*(auth:Auth, todos=newSeq[JsonNode](), params=newJObject(), errors=newJObject()):Future[string] {.async.} =
  let title = "Todo App"
  return applicationView(title, await impl(auth, todos, params, errors))

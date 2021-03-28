import json, asyncdispatch
import ../../../../../../../../src/basolato/view
import ../../layouts/application_view
import ../../layouts/post/header_view
import ../../layouts/post/input_view
import ../../layouts/post/errors_view
import ../../layouts/post/table_view

proc impl(auth:Auth, params:Params, posts:seq[JsonNode]):Future[string] {.async.} = tmpli html"""
<section class="section">
  <div class="container is-max-desktop">
    $(headerView(await auth.get("name")))
    $(inputView(params))
    $(await errorsView(auth))
    $(tableView(posts))
  </div>
</div>
"""

proc indexView*(auth:Auth, params:Params, posts=newSeq[JsonNode]()):Future[string] {.async.} =
  let title = "Todo App"
  return applicationView(title, await impl(auth, params, posts))

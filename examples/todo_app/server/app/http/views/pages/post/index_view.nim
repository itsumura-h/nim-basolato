import json, asyncdispatch
import ../../../../../../../../src/basolato/view
import ../../layouts/application_view
import ../../layouts/post/header_view
import ../../layouts/post/input_view
import ../../layouts/post/errors_view
import ../../layouts/post/table_view

proc impl(params, errors:JsonNode, client:Client, posts:seq[JsonNode]):Future[string] {.async.} = tmpli html"""
<section class="section">
  <div class="container is-max-desktop">
    $(headerView(await client.get("name")))
    $(inputView(params, errors))
    $(errorsView(errors))
    $(tableView(posts))
  </div>
</div>
"""

proc indexView*(client:Client, posts=newSeq[JsonNode]()):Future[string] {.async.} =
  let title = "Todo App"
  let (params, errors) = await client.getValidationResult()
  return applicationView(title, await impl(params, errors, client, posts))

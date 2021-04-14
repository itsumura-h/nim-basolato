import json
import ../../../../../../../src/basolato/view
import ../../layouts/application_view

proc impl(client:Client):Future[string] {.async.} = tmpli html"""
<a href="/">go back</a>
<form method="POST">
  $(csrfToken())
  <button type="submit">set flash</button>
</form>

<form method="POST" action="/sample/flash/leave">
  $(csrfToken())
  <button type="submit">leave</button>
</form>

$for key, val in await(client.getFlash()).pairs{
  <p>$(val.get())</p>
}
"""

proc indexView*(client:Client):Future[string] {.async.} =
  const title = "Flash message"
  return applicationView(title, await impl(client))

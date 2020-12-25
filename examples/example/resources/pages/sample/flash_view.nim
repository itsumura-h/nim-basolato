import json
import ../../../../../src/basolato/view
import ../../layouts/application_view

proc impl(auth:Auth):Future[string] {.async.} = tmpli html"""
<a href="/">go back</a>
<form method="POST">
  $(csrfToken())
  <button type="submit">set flash</button>
</form>

<form method="POST" action="/sample/flash/leave">
  $(csrfToken())
  <button type="submit">leave</button>
</form>

$for key, val in await(auth.getFlash()).pairs{
  <p>$(val.get())</p>
}
"""

proc indexView*(auth:Auth):Future[string] {.async.} =
  const title = "Flash message"
  return applicationView(title, await impl(auth))

import json
import ../../../../../src/basolato/view
import ../../layouts/application_view

proc impl(auth:Auth):string = tmpli html"""
<a href="/">go back</a>
<form method="POST">
  $(csrfToken())
  <button type="submit">set flash</button>
</form>

<form method="POST" action="/sample/flash/leave">
  $(csrfToken())
  <button type="submit">leave</button>
</form>

$for key, val in auth.getFlash().pairs{
  <p>$(val.get())</p>
}
"""

proc indexView*(auth:Auth):string =
  const title = "Flash message"
  return applicationView(title, impl(auth))

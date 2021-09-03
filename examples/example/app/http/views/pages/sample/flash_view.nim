import json
import ../../../../../../../src/basolato/view
import ../../layouts/application_view

style "css", style:"""
.className {
}
"""

proc impl(client:Client):Future[string]{.async.} = tmpli html"""
<main>
  <a href="/">go back</a>
  <section>
    <form method="POST">
      $(csrfToken())
      <button type="submit">set flash</button>
    </form>
  </section>
  <section>
    $for key, val in await(client.getFlash()).pairs{
      <p>$(val.get())</p>
    }
  </section>
</main>
"""

proc flashView*(client:Client):Future[string]{.async.} =
  const title = "Flash message"
  return applicationView(title, await impl(client))

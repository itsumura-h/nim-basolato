import json
import ../../../../../../../src/basolato/view
import ../../layouts/application_view


proc impl(context:Context):Future[Component]{.async.} =
  let style = styleTmpl(Css, """
    .className {
    }
  """)
  
  tmpl"""
    <main>
      <a href="/">go back</a>
      <section>
        <form method="POST">
          $(csrfToken())
          <button type="submit">set flash</button>
          $for key, val in context.getFlash().await.pairs{
            <p>$(val)</p>
          }
        </form>
      </section>
    </main>
  """

proc flashView*(context:Context):Future[Component]{.async.} =
  const title = "Flash message"
  return applicationView(title, await impl(context))

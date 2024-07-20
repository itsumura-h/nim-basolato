import std/asyncdispatch
import std/json
import ../../../../../../../src/basolato/view


proc flashPage*():Future[Component] {.async.} =
  let context = context()
  let flashMessageList = context.getFlash().await

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
          $for key, val in flashMessageList.pairs{
            <p>$(val)</p>
          }
        </form>
      </section>
    </main>
  """

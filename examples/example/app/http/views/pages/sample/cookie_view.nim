import json, asyncdispatch
import ../../../../../../../src/basolato/view
import ../../layouts/application_view



proc impl(cookies:JsonNode):Future[Component] {.async.} =
  let style = styleTmpl(Css, """
    .className {
    }
  """)

  tmpl"""
    <main>
      <article>
        <a href="/">go back</a>
        <hr>
        <form method="post">
          $(csrfToken())
          <input type="text" name="key" placeholder="key">
          <input type="text" name="value" placeholder="value">
          <button type="submit">send</button>
        </form>
        <form method="post" action="/sample/cookie/update">
          $(csrfToken())
          <input type="text" name="key" placeholder="key">
          <input type="text" name="days" placeholder="days">
          <button type="submit">update expire</button>
        </form>
        <form method="post" action="/sample/cookie/delete">
          $(csrfToken())
          <input type="text" name="key" placeholder="key">
          <button type="submit">delete</button>
        </form>
        <form method="post" action="/sample/cookie/destroy">
          $(csrfToken())
          <button type="submit">delete all</button>
        </form>
        <div>
          <ul>
            $for key, val in cookies{
              <li>$(key)=$(val)</li>
            }
          </ul>
        </div>
      </article>
    </main>
  """

proc cookieView*(cookies:JsonNode):Future[Component] {.async.} =
  let title = "Cookie"
  return applicationView(title, impl(cookies).await)

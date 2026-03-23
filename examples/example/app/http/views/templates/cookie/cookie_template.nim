import std/json
import ../../../../../../../src/basolato/view
import ../../presenters/cookie/cookie_page_viewmodel


proc cookieTemplate*(vm: CookiePageViewModel): Component =
  let style = styleTmpl(Css, """
    .className {
    }
  """)
  let csrfTokenStr = vm.csrfToken

  tmpl"""
    <main>
      <article>
        <a href="/">go back</a>
        <hr>
        <form method="post">
          <input type="hidden" name="csrf_token" value="$(escapeHtmlAttr(csrfTokenStr))">
          <input type="text" name="key" placeholder="key">
          <input type="text" name="value" placeholder="value">
          <button type="submit">send</button>
        </form>
        <form method="post" action="/sample/cookie/update">
          <input type="hidden" name="csrf_token" value="$(escapeHtmlAttr(csrfTokenStr))">
          <input type="text" name="key" placeholder="key">
          <input type="text" name="days" placeholder="days">
          <button type="submit">update expire</button>
        </form>
        <form method="post" action="/sample/cookie/delete">
          <input type="hidden" name="csrf_token" value="$(escapeHtmlAttr(csrfTokenStr))">
          <input type="text" name="key" placeholder="key">
          <button type="submit">delete</button>
        </form>
        <form method="post" action="/sample/cookie/destroy">
          <input type="hidden" name="csrf_token" value="$(escapeHtmlAttr(csrfTokenStr))">
          <button type="submit">delete all</button>
        </form>
        <div>
          <ul>
            $for key, val in vm.cookies.pairs{
              <li>$(key)=$(val)</li>
            }
          </ul>
        </div>
      </article>
    </main>
  """

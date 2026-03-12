import std/json
import ../../../../../../../src/basolato/view
import ../../presenters/flash/flash_page_viewmodel


proc flashTemplate*(vm: FlashPageViewModel): Component =
  let style = styleTmpl(Css, """
    .className {
    }
  """)
  
  tmpl"""
    <main>
      <a href="/">go back</a>
      <section>
        <form method="POST">
          <input type="hidden" name="csrf_token" value="$(escapeHtmlAttr(vm.csrfToken))">
          <button type="submit">set flash</button>
          $for key, val in vm.flashMessages.pairs{
            <p>$(val)</p>
          }
        </form>
      </section>
    </main>
  """

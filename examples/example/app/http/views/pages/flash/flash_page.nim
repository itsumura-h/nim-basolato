import std/asyncdispatch
import std/json
import ../../../../../../../src/basolato/view
import ../../presenters/flash/flash_page_viewmodel


proc flashTemplate*(vm: FlashPageViewModel): Component


proc flashPage*():Future[Component] {.async.} =
  let context = context()
  let flashMessageList = context.getFlash().await

  let vm = FlashPageViewModel.new(flashMessageList)
  return flashTemplate(vm)


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
          $(csrfToken())
          <button type="submit">set flash</button>
          $for key, val in vm.flashMessages.pairs{
            <p>$(val)</p>
          }
        </form>
      </section>
    </main>
  """

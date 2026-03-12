import ../../../../../../../src/basolato/view
import ../../presenters/login/login_page_viewmodel


proc loginTemplate*(vm: LoginPageViewModel):Component =
  let formParams = vm.formParams
  let formErrors = vm.formErrors
  let loginUser = (isLogin: vm.isLogin, name: vm.name)
  let csrfTokenStr = vm.csrfToken

  let style = styleTmpl(Css, """
    <style>
      ul{
        background-color: pink;
        color: red;
      }
    </style>
  """)

  tmpl"""
    <main>
      <a href="/">go back</a>
      <section>
        $if loginUser.isLogin{
          <form method="POST" action="/sample/logout">
            <header>
              <h2>You are logged in!</h2>
              <p>Login Name: $(loginUser.name)</p>
            </header>
            <input type="hidden" name="csrf_token" value="$(escapeHtmlAttr(csrfTokenStr))">
            <button type="submit">Logout</button>
          </form>
        }
        $else{
          <form method="POST">
            <header>
              <h2>Login</h2>
            </header>
            $if formErrors.len > 0{
              <ul>
                $for error in formErrors{
                  <li>$(error)</li>
                }
              </ul>
            }
            <input type="hidden" name="csrf_token" value="$(escapeHtmlAttr(csrfTokenStr))">
            <input type="text" name="name" placeholder="name" value="$(formParams.old("name"))">
            <input type="password" name="password" placeholder="password">
            <button type="submit">Login</button>
          </form>
        }
      </section>
    </main>
    $(style)
  """

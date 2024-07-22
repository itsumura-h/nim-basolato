import ../../../../../../../src/basolato/view
import ../../signals/form_signal
import ../../signals/login_signal


proc loginTemplate*():Component =
  let formParams = formParamsSignal.value()
  let formErrors = formErrorsSignal.value()
  let loginUser = loginUserSignal.value()

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
            $(csrfToken())
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
            $(csrfToken())
            <input type="text" name="name" placeholder="name" value="$(formParams.old("name"))">
            <input type="password" name="password" placeholder="password">
            <button type="submit">Login</button>
          </form>
        }
      </section>
    </main>
    $(style)
  """

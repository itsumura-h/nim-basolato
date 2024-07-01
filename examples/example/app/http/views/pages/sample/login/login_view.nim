import asyncdispatch
import ../../../../../../../../src/basolato/view
import ../../../layouts/application_view
import ./login_view_model


proc impl(viewModel:LoginViewModel):Component =
  let style = styleTmpl(Css, """
    .className {
    }
  """)

  tmpl"""
    <main>
      <a href="/">go back</a>
      <section>
        $if viewModel.isLogin{
          <form method="POST" action="/sample/logout">
            <header>
              <h2>You are logged in!</h2>
              <p>Login Name: $(viewModel.name)</p>
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
            $(csrfToken())
            <input type="text" name="name" placeholder="name">
            <input type="text" name="password" placeholder="password">
            <button type="submit">Login</button>
          </form>
        }
      </section>
    </main>
  """

proc loginView*(viewModel:LoginViewModel):Component =
  let title = "Login"
  return applicationView(title, impl(viewModel))

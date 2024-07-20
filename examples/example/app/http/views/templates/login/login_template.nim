import ../../../../../../../src/basolato/view
import ../../signals/login_signal


proc loginTemplate*():Component =
  let loginUser = loginUserSignal.value()

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
            $(csrfToken())
            <input type="text" name="name" placeholder="name">
            <input type="text" name="password" placeholder="password">
            <button type="submit">Login</button>
          </form>
        }
      </section>
    </main>
  """

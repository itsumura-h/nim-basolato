import asyncdispatch
import ../../../../../../../src/basolato/view
import ../../layouts/application_view

style "css", style:"""
.className {
}
"""

proc impl(client:Client):Future[string]{.async.} = tmpli html"""
<main>
  <a href="/">go back</a>
  <section>
    $if await client.isLogin(){
      <form method="POST" action="/sample/logout">
        <header>
          <h2>You are logged in!</h2>
          <p>Login Name: $(await client.get("name"))</p>
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

proc loginView*(client:Client):Future[string]{.async.} =
  let title = "Login"
  return applicationView(title, await impl(client))

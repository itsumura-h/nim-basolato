import ../../../../../../../src/basolato/view
import ../../layouts/application_view

proc impl(auth:Auth):Future[string] {.async.} = tmpli html"""
<a href="/">go back</a>
<div>
  $if await auth.isLogin(){
    <h1>Login Name: $(await auth.get("name"))</h1>
    <form method="POST" action="/sample/logout">
      $(csrfToken())
      <button type="submit">Logout</button>
    </form>
  }
  $else{
    <form method="POST">
      $(csrfToken())
      <input type="text" name="name">
      <input type="text" name="password">
      <button type="submit">login</button>
    </form>
  }
</div>
"""

proc loginView*(auth:Auth):Future[string] {.async.} =
  const title = "Login"
  return applicationView(title, await impl(auth))

import ../../../../../src/basolato_httpbeast/view
import ../../layouts/application_view

proc impl(auth:Auth): string = tmpli html"""
<a href="/">go back</a>
<div>
  $if auth.isLogin(){
    <h1>Login Name: $(auth.get("name"))</h1>
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

proc loginView*(auth:Auth):string =
  const title = "Login"
  return applicationView(title, impl(auth))

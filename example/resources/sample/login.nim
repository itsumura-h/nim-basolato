import ../../../src/basolato/view
import ../../../src/basolato/csrf_token
import ../../../src/basolato/auth

proc loginHtml*(auth:Auth): string = tmpli html"""
<a href="/">go back</a>
<div>
  $if auth.isLogin {
    <h1>Login Name: $(auth.get("name"))</h1>
    <form method="POST" action="/sample/logout">
      $(csrfToken())
      <button type="submit">Logout</button>
    </form>
  }
  $else {
    <form method="POST">
      $(csrfToken())
      <input type="text" name="name" value="$(auth.get("name"))">
      <input type="text" name="password">
      <button type="submit">login</button>
    </form>
  }
</div>
"""
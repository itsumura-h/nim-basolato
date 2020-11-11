import ../../../../../src/basolato/view
import ../../layouts/application_view

proc impl():string = tmpli html"""
<form method="POST">
  $(csrfToken())
  <input type="text" name="email" placeholder="email">
  <input type="password" name="password" placeholder="password">
  <button type="submit">signin</button>
</form>
<a href="/signup">Sign up here</a>
"""

proc signinView*():string =
  let title = "Sign in"
  return applicationView(title, impl())

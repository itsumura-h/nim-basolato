import ../../../../src/basolato/view
import ../layouts/application

proc impl():string = tmpli html"""
<h1>Login</h1>
<form method="POST">
  $(csrf_token())
  <div>
    <input type="text" name="email" placeholder="email">
  </div>

  <div>
    <input type="password" name="password" placeholder="password">
  </div>

  <button type="submit">login</button>
</form>
<a href="/signin">Sign in here</a>
"""

proc loginView*(this:View):string =
  let title = ""
  return this.applicationView(title, impl())

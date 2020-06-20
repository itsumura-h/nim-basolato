import json
import ../../../../src/basolato/view
import ../layouts/application

proc impl(user, errors=newJObject()):string = tmpli html"""
<h1>Sign In</h1>
<form method="POST">
  $(csrf_token())
  <div>
    <input type="text" name="name" placeholder="name" value="$(user["name"].get)">
      $if errors.hasKey("name"){
        <ul>
          $for error in errors["name"]{
            <li>$(error.get)</li>
          }
        </ul>
      }
  </div>

  <div>
    <input type="text" name="email" placeholder="email" value="$(user["email"].get)">
      $if errors.hasKey("email"){
        <ul>
          $for error in errors["email"]{
            <li>$(error.get)</li>
          }
        </ul>
      }
  </div>

  <div>
    <input type="password" name="password" placeholder="password">
      $if errors.hasKey("password"){
        <ul>
          $for error in errors["password"]{
            <li>$(error.get)</li>
          }
        </ul>
      }
  </div>

  <button type="submit">sign in</button>
</form>
<a href="/login">Log in here</a>
"""

proc signinView*(this:View, user, errors=newJObject()):string =
  let title = "SignIn"
  var user = user
  if user.len == 0:
    user = %*{"name": "", "email": ""}
  return this.applicationView(title, impl(user, errors))

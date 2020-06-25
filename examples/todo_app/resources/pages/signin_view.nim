import json
import ../../../../src/basolato/view
import ../layouts/application

proc impl(params, errors=newJObject()):string = tmpli html"""
<h1>Sign In</h1>
<form method="POST">
  $(csrf_token())
  $if errors.hasKey("exception"){
    <div>
      $(errors["exception"].get)
    </div>
  }
  <div>
    <input type="text" name="name" placeholder="name" value="$(old(params, "name"))">
      $if errors.hasKey("name"){
        <ul>
          $for error in errors["name"]{
            <li>$(error.get)</li>
          }
        </ul>
      }
  </div>

  <div>
    <input type="text" name="email" placeholder="email" value="$(old(params, "email"))">
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

proc signinView*(this:View, params, errors=newJObject()):string =
  let title = "SignIn"
  return this.applicationView(title, impl(params, errors))

import json
import ../../../../src/basolato/view
import ../layouts/application

proc impl(params, errors:JsonNode):string = tmpli html"""
<h1>Login</h1>
<form method="POST">
  $(csrf_token())
  $if errors.hasKey("exception"){
    <div class="errors">
      $(errors["exception"].get)
    </div>
  }
  <div>
    <input type="text" name="email" placeholder="email", value="$(old(params, "email"))">
    $if errors.hasKey("email"){
      <ul class="errors">
        $for error in errors["email"]{
          <li>$(error.get)</li>
        }
      </ul>
    }
  </div>

  <div>
    <input type="password" name="password" placeholder="password">
    $if errors.hasKey("password"){
      <ul  style="background-color: pink; color: red;">
        $for error in errors["password"]{
          <li>$(error.get)</li>
        }
      </ul>
    }
  </div>

  <button type="submit">login</button>
</form>
<a href="/signin">Sign in here</a>
"""

proc loginView*(this:View, params, errors=newJObject()):string =
  let title = ""
  return this.applicationView(title, impl(params, errors))

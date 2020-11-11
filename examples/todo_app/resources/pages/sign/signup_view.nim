import json, tables
import ../../../../../src/basolato/view
import ../../layouts/application_view


let style = block:
  var css = newCss()
  css.set("errors", "", """
    background-color: pink;
    color: red;
  """)
  css

proc impl(params:TableRef, errors:JsonNode):string = tmpli html"""
$(style.define())
<form method="POST">
  $(csrfToken())
  <div>
    <input type="text" name="name" placeholder="name" value="$(old(params, "name"))">
    $if errors.hasKey("name") {
      <ul class="$(style.get("errors"))">
        $for error in errors["name"] {
          <li>$(error.get())</li>
        }
      </ul>
    }
  </div>

  <div>
    <input type="text" name="email" placeholder="email" value="$(old(params, "email"))">
    $if errors.hasKey("email") {
      <ul class="$(style.get("errors"))">
        $for error in errors["email"] {
          <li>$(error.get())</li>
        }
      </ul>
    }
  </div>

  <div>
    <input type="password" name="password" placeholder="password">
    $if errors.hasKey("password") {
      <ul class="$(style.get("errors"))">
        $for error in errors["password"] {
          <li>$(error.get())</li>
        }
      </ul>
    }
  </div>

  <div>
    <button type="submit">signup</button>
  </div>
</form>
<a href="/signin">Sign in here</a>
"""

proc signupView*(params=newTable[string, string](), errors=newJObject()):string =
  let title = "Sign up"
  return applicationView(title, impl(params, errors))

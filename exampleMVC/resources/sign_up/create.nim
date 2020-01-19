import json
import ../../../src/basolato/view
import ../base

proc createHtmlImpl(name:string, email:string, errors:JsonNode): string = tmpli html"""
<h2>Sign Up</h2>
$if errors.hasKey("general") {
  <p style="background-color: deeppink">$(errors["general"].getStr)</p>
}
<form method="post">
  $(csrfToken())
  <div>
    <p>name</p>
    $if errors.hasKey("name") {
      <p><li>$(errors["name"].getStr)</li></p>
    }
    <p><input type="text" value="$name" name="name"></p>
  </div>
  <div>
    <p>email</p>
    $if errors.hasKey("email") {
      <p><li>$(errors["email"].getStr)</li></p>
    }
    <p><input type="text" value="$email" name="email"></p>
  </div>
  <div>
    <p>password</p> 
    $if errors.hasKey("password") {
      <p><li>$(errors["password"].getStr)</li></p>
    }
    <p><input type="password" name="password"></p>
  </div>
  <button type="submit">create</button>
</form>
"""

proc createHtml*(name="", email="", errors=newJObject()): string =
  baseHtml(createHtmlImpl(name, email, errors))

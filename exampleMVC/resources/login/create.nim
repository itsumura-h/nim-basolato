import json
# import ../../../src/basolato/view
import ../../../src/basolato/private
import ../../../src/basolato/session
import ../base

proc createHtmlImpl(login:Login, email:string, errors:JsonNode): string = tmpli html"""
<h2>login</h2>
$if errors.hasKey("general") {
  <p style="background-color: deeppink">$(errors["general"].getStr)</p>
}
<form method="post">
  $(csrfToken(login))
  <div>
    <p>email</p>
    $if errors.hasKey("email") {
      <ul>
        $for row in errors["email"] {
          <li>$row</li>
        }
      </ul>
    }
    <p><input type="text" value="$email" name="email"></p>
  </div>
  <div>
    <p>password</p> 
    $if errors.hasKey("password") {
      <ul>
        $for row in errors["password"] {
          <li>$row</li>
        }
      </ul>
    }
    <p><input type="password" name="password"></p>
  </div>
  <button type="submit">create</button>
</form>
"""

proc createHtml*(login:Login, email="", errors=newJObject()): string =
  baseHtml(login, createHtmlImpl(login, email, errors))

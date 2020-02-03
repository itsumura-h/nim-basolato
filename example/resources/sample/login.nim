import ../../../src/basolato/view
import ../../../src/basolato/csrf_token
import ../../../src/basolato/auth

proc loginHtml*(auth:Auth): string = tmpli html"""
<form method="POST">
  $(csrfToken())
  <input type="text" name="name" value="$(auth.get("name"))">
  <input type="text" name="password">
  <button type="submit">submit</button>
</form>
"""
import ../../../src/basolato/view
import ../../../src/basolato/csrf_token

proc loginHtml*(name=""): string = tmpli html"""
<form method="POST">
  $(csrfToken())
  <input type="text" name="name" value="$name">
  <input type="text" name="password">
  <button type="submit">submit</button>
</form>
"""
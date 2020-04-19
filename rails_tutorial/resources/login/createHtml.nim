import json
import ../../../src/basolato/view
import ../layouts/application
import ../layouts/shared/error_messages

proc impl(user:JsonNode, errors:JsonNode):string = tmpli html"""
<h1>Log in</h1>
<div class="row">
  <div class="col-md-6 col-md-offset-3">
    <form method="post">
      $(error_messages(errors))
      $(csrf_token())
      <label>Email</label>
      <input type="text" name="email" value="$(user["email"].get)" class="form-control">

      <label>Password</label>
      <input type="text" name="password" class="form-control">

      <button type="submit" class="btn btn-primary form-control">Log in</button>
    </form>
    <p>New user? <a href="/signup">Sign up now!</a></p>
  </div>
</div>
"""

proc createHtml*(user=newJNull(), errors=newJNull()):string =
  var user = user
  if user.kind == JNull:
    user = %*{"name": "", "email": ""}  
  applicationHtml("Log in", impl(user, errors))

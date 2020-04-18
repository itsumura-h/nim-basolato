import json
import basolato/view
import ../layouts/application
import ../shared/error_messages

proc impl(user:JsonNode, errors:JsonNode):string = tmpli html"""
<h1>Sign up</h1>
<div class="row">
  <div class="col-md-6 col-md-offset-3">
    <form method="post" action="/signup">
      $(error_messages(errors))
      $(csrf_token())
      <label>Name</label>
      <input type="text" name="name" value="$(user["name"].get)" class="form-control">

      <label>Email</label>
      <input type="text" name="email" value="$(user["email"].get)" class="form-control">

      <label>Password</label>
      <input type="text" name="password" class="form-control">

      <label>Password confirm</label>
      <input type="text" name="password_confirm" class="form-control">

      <button type="submit" class="btn btn-primary">Create my account</button>
    </form>
  </div>
</div>
"""

proc createHtml*(user:JsonNode=newJNull(), errors=newJNull()):string =
  var user = user
  if user.kind == JNull:
    user = %*{"name": "", "email": ""}
  applicationHtml("Sign up", impl(user, errors))

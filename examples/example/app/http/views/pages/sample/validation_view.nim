import tables
import ../../../../../../../src/basolato/view
import ../../layouts/application_view

style "css", style:"""
.className {
}
.error {
  background-color: pink;
  color: red;
}
"""

proc impl(params:Params):string = tmpli html"""
$(style)
<div class="$(style.get("className"))">
  <form method="POST">
    $(csrfToken())
    <p><input type="text" name="name" placeholder="name"></p>
    $if params.hasError("name"){
      <ul class="$(style.get("error"))">
        $for error in params.errors["name"] {
          <li>$(error.get)</li>
        }
      </ul>
    }
    <p><input type="password" name="password" placeholder="password"></p>
    $if params.hasError("password"){
      <ul class="$(style.get("error"))">
        $for error in params.errors["password"] {
          <li>$(error.get)</li>
        }
      </ul>
    }
    <p><input type="password" name="password_confirmation" placeholder="password confirmation"></p>
    $if params.hasError("password_confirmation"){
      <ul class="$(style.get("error"))">
        $for error in params.errors["password_confirmation"] {
          <li>$(error.get)</li>
        }
      </ul>
    }
    <p><input type="number" name="number" placeholder="number between 1 ~ 10"></p>
    $if params.hasError("number"){
      <ul class="$(style.get("error"))">
        $for error in params.errors["number"] {
          <li>$(error.get)</li>
        }
      </ul>
    }
    <p><input type="text" name="float" placeholder="float between 0.1 ~ 1.0"></p>
    $if params.hasError("float"){
      <ul class="$(style.get("error"))">
        $for error in params.errors["float"] {
          <li>$(error.get)</li>
        }
      </ul>
    }
    <p><button type="submit">send</button></p>
  </form>
</div>
"""

proc validationView*(params:Params):string =
  let title = ""
  return applicationView(title, impl(params))

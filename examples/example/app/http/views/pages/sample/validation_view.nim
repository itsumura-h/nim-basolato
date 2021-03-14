import basolato/view
import ../../layouts/application_view

style "css", style:"""
.className {
}
"""

proc impl():string = tmpli html"""
$(style)
<div class="$(style.get("className"))">
  <form method="POST">
    $(csrfToken())
    <p><input type="text" name="name" placeholder="name"></p>
    <p><input type="password" name="password" placeholder="password"></p>
    <p><input type="number" name="number" placeholder="number between 1 ~ 10"></p>
    <p><input type="text" name="float" placeholder="float"></p>
    <p><button type="submit">send</button></p>
  </form>
</div>
"""

proc validationView*():string =
  let title = ""
  return applicationView(title, impl())

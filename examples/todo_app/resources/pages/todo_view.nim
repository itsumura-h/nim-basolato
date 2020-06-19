import ../../../../src/basolato/view
import ../layouts/application

proc impl():string = tmpli html"""
<form method="POST">
  $(csrfToken())
  <input type="text" name="todo">
  <button type="submit">add</button>
</form>
"""

proc todoView*(this:View):string =
  let title = "todo"
  return this.applicationView(title, impl())

import ../../../../../../../src/basolato/view
import ../../layouts/application_view

style "css", style:"""
.className {
}
"""

proc impl(id, name:string):string = tmpli html"""
$(style)
<div class="$(style.get("className"))">
  <p>id:$(id.get)</p>
  <p>name:$(name.get)</p>
  <a href="/signout"><b>sign out</b></a>
</div>
"""

proc indexView*(id, name:string):string =
  let title = ""
  return applicationView(title, impl(id, name))

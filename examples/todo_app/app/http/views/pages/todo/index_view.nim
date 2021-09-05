import basolato/view
import ../../layouts/application_view

style "css", style:"""
.className {
}
"""

proc impl():string = tmpli html"""
$(style)
<div class="$(style.get("className"))">
<a href="/signout"><b>sign out</b></a>
</div>
"""

proc indexView*():string =
  let title = ""
  return applicationView(title, impl())

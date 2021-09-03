import ../../../../../../../../src/basolato/view

style "css", style:
  """
.right{
  float: right;
}
"""

proc headerView*(name:string):string = tmpli html"""
$(style)
<div class="container">
  <span>Login: $name</span>
  <form method="POST" action="/signout" class="$(style.get("right"))">
    $(csrfToken())
    <button class="button is-info is-rounded">Logout</button>
  </form>
</div>
"""

import ../../../../../src/basolato/view

let style = block:
  var css = newCss()
  css.set("right", "", """
    float: right;
  """)
  css

proc headerView*(name:string):string = tmpli html"""
$(style.define())
<div class="container">
  <span>Login: $name</span>
  <form method="POST" action="/signout" class="$(style.get("right"))">
    $(csrfToken())
    <button class="button is-info is-rounded">Logout</button>
  </form>
</div>
"""

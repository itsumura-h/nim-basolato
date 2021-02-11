import ../../../../../../../src/basolato/view
import head_view

let style = block:
  var css = newCss()
  css.set("body", "", """
    background-color: #EEEEEE;
    min-height: 100vh;
  """)
  css

proc applicationView*(title:string, body:string):string = tmpli html"""
<!DOCTYPE html>
<html lang="en">
  $(headView(title))
<body>
  $(style.define())
  <div class="$(style.get("body"))">
    $body
  </div>
</body>
</html>
"""

import ../../../../../../../src/basolato/view
import head_view

style "css", style:
  """
.body {
  background-color: #EEEEEE;
  min-height: 100vh;
}
"""

proc applicationView*(title:string, body:string):string = tmpli html"""
<!DOCTYPE html>
<html lang="en">
  $(headView(title))
<body>
  $(style)
  <div class="$(style.element("body"))">
    $body
  </div>
</body>
</html>
"""

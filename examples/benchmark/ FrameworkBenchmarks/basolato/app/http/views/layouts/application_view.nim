import basolato/view
import head_view

proc applicationView*(title:string, body:string):string = tmpli html"""
<!DOCTYPE html>
<html lang="en">
  $(headView(title))
<body>
  $body
</body>
</html>
"""

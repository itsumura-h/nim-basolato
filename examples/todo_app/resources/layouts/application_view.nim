import ../../../../src/basolato/view
import head_view
import header_view

proc applicationView*(this:View, title:string, body:string):string = tmpli html"""
<!DOCTYPE html>
<html lang="en">
<head>
  $(headView(title))
</head>
<body>
  $(headerView(this))
  $body
</body>
</html>
"""

import ../../../../src/basolato/view
import head
import header

proc applicationView*(this:View, title:string, body:string):string = tmpli html"""
<!DOCTYPE html>
<html lang="en">
<head>
  $(headView())
  <title>$title</title>
</head>
<body>
  $(headerView(this))
  $body
</body>
</html>
"""

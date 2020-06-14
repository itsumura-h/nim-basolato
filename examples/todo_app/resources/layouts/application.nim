import ../../../../src/basolato/view
import head

proc applicationView*(this:View, title:string, body:string):string = tmpli html"""
<!DOCTYPE html>
<html lang="en">
<head>
  <title>$title</title>
  $(headView())
</head>
<body>
  $body
</body>
</html>
"""

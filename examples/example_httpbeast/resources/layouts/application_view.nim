import ../../../../src/basolato_httpbeast/view
import head_view

proc applicationView*(title:string, body:string):string = tmpli html"""
<!DOCTYPE html>
<html lang="en">
<head>
  $(headView())
  <title>$title</title>
</head>
<body>
  $body
</body>
</html>
"""
import basolato/view
import head

proc applicationView*(this:View, title:string, body:string):string = tmpli html"""
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

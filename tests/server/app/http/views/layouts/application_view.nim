import ../../../../../../src/basolato/view
import head_view

proc applicationView*(title:string, body:Component):Component = tmpl"""
<!DOCTYPE html>
<html lang="en">
<head>
  $(headView())
  <title>$(title)</title>
</head>
<body>
  $(body)
</body>
</html>
"""

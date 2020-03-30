import basolato/view

proc applicationHtml*(title:string, body:string):string = tmpli html"""
<!DOCTYPE html>
<html>
  <head>
    <title>$title | Ruby on Rails Tutorial Sample App</title>
    $(csrf_token())
  </head>
  <body>
    $body
  </body>
</html>
"""

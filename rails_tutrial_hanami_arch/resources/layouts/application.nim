import strformat
import basolato/view

import head, shim, header, footer

proc fullTitle*(title:string):string =
  var baseTitle = "Ruby on Rails Tutorial Sample App"
  if title.len == 0:
    return baseTitle
  else:
    return &"{title} | {baseTitle}"

proc applicationHtml*(title:string, body:string):string = tmpli html"""
<!DOCTYPE html>
<html>
  <head>
    <title>$(fullTitle(title))</title>
    $(headHtml())
    $(shimHtml())
  </head>
  <body>
    $(headerHtml())
    <div class="container">
      $body
      $(footerHtml())
    </div>
  </body>
</html>
"""

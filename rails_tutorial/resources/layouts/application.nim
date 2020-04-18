import strformat, json
import basolato/view

import head, shim, header, footer

proc fullTitle*(title:string):string =
  var baseTitle = "Ruby on Rails Tutorial Sample App"
  if title.len == 0:
    return baseTitle
  else:
    return &"{title} | {baseTitle}"

proc applicationHtml*(title:string, body:string, flash=newJObject()):string = tmpli html"""
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
      $for key, val in flash{
        <div class="alert alert-$key">$(val.get())</div>
      }
      $body
      $(footerHtml())
    </div>
  </body>
</html>
"""

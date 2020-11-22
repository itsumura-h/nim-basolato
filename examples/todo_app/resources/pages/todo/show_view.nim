import json
import basolato/view
import ../../layouts/application_view

let style = block:
  var css = newCss()
  css

proc impl(post:JsonNode):string = tmpli html"""
<h1>$(post["title"].get())</h1>
<div>$(post["content"].get())</div>
"""

proc showView*(post=newJObject()):string =
  let title = ""
  return applicationView(title, impl(post))

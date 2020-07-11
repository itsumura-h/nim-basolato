import json
import ../../../../src/basolato/view
import ../layouts/application

proc impl(todo:JsonNode):string = tmpli html"""
<p><a href="/">back</a></p>
<textarea readonly>$(todo["todo"].get)</textarea>
"""

proc todoDetailView*(this:View, todo:JsonNode):string =
  let title = ""
  return this.applicationView(title, impl(todo))

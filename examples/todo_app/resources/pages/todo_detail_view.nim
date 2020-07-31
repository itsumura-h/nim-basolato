import json
import ../../../../src/basolato/view
import ../layouts/application_view

proc impl(todo:JsonNode):string = tmpli html"""
<p><a href="/todo">back</a></p>
<div>$(todo["todo"].get)</div>
"""

proc todoDetailView*(this:View, todo:JsonNode):string =
  let title = "todo detail"
  return this.applicationView(title, impl(todo))

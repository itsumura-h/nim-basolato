import json
import ../../../../../../../../src/basolato/view

style "css", style:
  """
.errors{
  background-color: pink;
  color: red;
}
"""

proc errorsView*(errors:JsonNode):string = tmpli html"""
$(style)
$if errors.hasKey("core"){
  <div class="container $(style.get("errors"))">
    $for v in errors["core"]{
      <p class="content">$(v.get)</p>
    }
  </div>
}
"""

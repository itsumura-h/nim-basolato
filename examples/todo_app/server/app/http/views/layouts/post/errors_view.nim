import json
import ../../../../../../../../src/basolato/view

style "css", style:
  """
.errors{
  background-color: pink;
  color: red;
}
"""

proc errorsView*(auth:Auth):Future[string] {.async.} = tmpli html"""
$(style)
$if await auth.hasFlash("error"){
  <div class="container $(style.get("errors"))">
    $for k, v in await(auth.getFlash()).pairs{
      <p class="content">$(v.get)</p>
    }
  </div>
}
"""

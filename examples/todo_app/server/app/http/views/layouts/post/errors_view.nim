import json
import ../../../../../../../../src/basolato/view

let style = block:
  var css = newCss()
  css.set("errors", "", """
    background-color: pink;
    color: red;
  """)
  css

proc errorsView*(auth:Auth):Future[string] {.async.} = tmpli html"""
$(style.define())
$if await auth.hasFlash("error"){
  <div class="container $(style.get("errors"))">
    $for k, v in await(auth.getFlash()).pairs{
      <p class="content">$(v.get)</p>
    }
  </div>
}
"""

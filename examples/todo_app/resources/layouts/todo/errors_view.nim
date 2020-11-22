import json
import ../../../../../src/basolato/view

let style = block:
  var css = newCss()
  css.set("errors", "", """
    background-color: pink;
    color: red;
  """)
  css

proc errorsView*(auth:Auth):string = tmpli html"""
$(style.define())
$if auth.hasFlash("error"){
  <div class="container $(style.get("errors"))">
    $for k, v in auth.getFlash().pairs{
      <p class="content">$(v.get)</p>
    }
  </div>
}
"""

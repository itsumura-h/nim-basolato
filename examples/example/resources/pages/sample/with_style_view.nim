import ../../../../../src/basolato/view
import ../../layouts/application_view

let style1 = block:
  var css = newCss()
  css.set("background", "", """
    height: 200px;
    width: 200px;
    background-color: red;
  """)
  css

proc component1():string = tmpli html"""
$(style1.define())
<div class="$(style1.get("background"))"></div>
"""

let style2 = block:
  var css = newCss()
  css.set("background", "", """
    height: 200px;
    width: 200px;
    background-color: blue;
  """)
  css.set("background", ":hover", """
    background-color: green;
  """)
  css

proc component2():string = tmpli html"""
$(style2.define())
<div class="$(style2.get("background"))"></div>
"""

proc impl():string = tmpli html"""
$(component1())
$(component2())
"""

proc withStyleView*():string =
  let title = ""
  return applicationView(title, impl())

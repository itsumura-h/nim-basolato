import ../../../../../../../src/basolato/view
import ../../layouts/application_view

style "css", style1:"""
.className{
  height: 200px;
  width: 200px;
  background-color: red;
}
.className:hover{
  background-color: blue;
}
"""
proc component1():string = tmpli html"""
$(style1)
<div class="$(style1.get("className"))"></div>
"""

style "css", style2:"""
.className{
  height: 200px;
  width: 200px;
  background-color: blue;
}
.className:hover{
  background-color: green;
}
"""
proc component2():string = tmpli html"""
$(style2)
<div class="$(style2.get("className"))"></div>
"""

proc impl():string = tmpli html"""
$(component1())
$(component2())
"""

proc withStyleView*():string =
  let title = ""
  return applicationView(title, impl())

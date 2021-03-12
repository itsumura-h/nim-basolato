import ../../../../../../../src/basolato/view
import ../../layouts/application_view

style "scss", style1:
  """
.background{
  height: 200px;
  width: 200px;
  background-color: red;
  &:hover{
    background-color: blue;
  }
}
"""
proc component1():string = tmpli html"""
$(style1)
<div class="$(style1.get("background"))"></div>
"""

style "css", style2:
  """
.background{
  height: 200px;
  width: 200px;
  background-color: blue;
}
.background:hover{
  background-color: green;
}
"""
proc component2():string = tmpli html"""
$(style2)
<div class="$(style2.get("background"))"></div>
"""

proc impl():string = tmpli html"""
$(component1())
$(component2())
"""

proc withStyleView*():string =
  let title = ""
  return applicationView(title, impl())

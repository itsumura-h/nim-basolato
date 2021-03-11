import ../../../../../../../src/basolato/view
import ../../layouts/application_view

style "sass", style1:
  """
.background1{
  height: 200px;
  width: 200px;
  background-color: red;
}
"""

proc component1():string = tmpli html"""
$(style1())
<div class="background1"></div>
"""

style "css", style2:
  """
.background2{
  height: 200px;
  width: 200px;
  background-color: blue;
}
.background2:hover{
  background-color: green;
}
"""

proc component2():string = tmpli html"""
$(style2())
<div class="background2"></div>
"""

proc impl():string = tmpli html"""
$(component1())
$(component2())
"""

proc withStyleView*():string =
  let title = ""
  return applicationView(title, impl())

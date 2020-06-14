import ../../../../src/basolato/view
import ../layouts/application

proc impl():string = tmpli html"""
<h1>todo</h1>
"""

proc todoView*(this:View):string =
  let title = "todo"
  return this.applicationView(title, impl())

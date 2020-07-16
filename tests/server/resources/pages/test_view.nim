import ../../../../src/basolato/view
import ../layouts/application

proc impl():string = tmpli html"""
<h1>test template</h1>
"""

proc testView*(this:View):string =
  return impl()

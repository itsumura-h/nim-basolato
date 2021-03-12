import ../../../../../../src/basolato/view
import ../layouts/application_view

proc impl():string = tmpli html"""
<h1>test template</h1>
"""

proc testView*():string =
  return impl()

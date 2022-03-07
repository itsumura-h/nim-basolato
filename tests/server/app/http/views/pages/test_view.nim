import ../../../../../../src/basolato/view

proc impl():string = tmpli html"""
<h1>test template</h1>
$(csrfToken())
"""

proc testView*():string =
  return impl()

import ../../../../../../src/basolato/view

proc impl():Component = tmpli html"""
<h1>test template</h1>
$(csrfToken())
"""

proc testView*():string =
  return $impl()

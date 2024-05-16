import ../../../../../../src/basolato/view

proc impl():Component = tmpl"""
<h1>test template</h1>
$(csrfToken())
"""

proc testView*():string =
  return $impl()

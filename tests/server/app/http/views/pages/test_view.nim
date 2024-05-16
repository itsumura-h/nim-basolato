import ../../../../../../src/basolato/view

proc impl():Component = tmpl"""
<h1>test template</h1>
"""

proc testView*():string =
  return $impl()

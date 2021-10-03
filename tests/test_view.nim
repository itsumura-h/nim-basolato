import unittest, json
include ../src/basolato/view

block:
  var data = newJString("data")
  check data.get() == "data"

block:
  var data = newJInt(1)
  check data.get() == "1"

block:
  var data = newJFloat(1.1)
  check data.get() == "1.1"

block:
  var data = newJBool(true)
  check data.get() == "true"
  data = newJBool(false)
  check data.get() == "false"

block:
  var data = newJNull()
  check data.get() == ""

block:
  style "css", style:"""
<style type="text/css">
  .className{
    color: red;
  }
</style>
"""
  let className = style.element("className")
  let expanded = fmt("""
<style type="text/css">
  .[className]{
    color: red;
  }
</style>
""", '[', ']')
  check $style == expanded

block:
  script ["idName"], script:"""
<script>
  let el = document.getElementById('idName')
</script>
"""
  let idName = script.element("idName")
  let expanded = fmt("""
<script>
  let el = document.getElementById('{idName}')
</script>
""")
  check $script == expanded
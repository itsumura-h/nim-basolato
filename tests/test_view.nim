discard """
  cmd: "nim c -r $file"
"""

import std/unittest
import std/json
import std/strformat
import ../src/basolato/view


block:
  # html expression
  proc a():Component = tmpli html"""
    <p>aaa</p>
  """ 
  check a().toString() == "<p>aaa</p>"

block:
  # xml encode
  proc a(arg:string):Component = tmpli html"""
    <p>$(arg)</p>
  """
  let arg = "<script>alert('hello')</script>"
  check a(arg).toString() == "<p>&lt;script&gt;alert('hello')&lt;/script&gt;</p>"

block:
  # int
  proc a(arg:int):Component = tmpli html"""
    <p>$(arg)</p>
  """
  let arg = 1
  check a(arg).toString() == "<p>1</p>"

block:
  # float
  proc a(arg:float):Component = tmpli html"""
    <p>$(arg)</p>
  """
  let arg = 1.1
  check a(arg).toString() == "<p>1.1</p>"

block:
  # bool
  proc a(arg:bool):Component = tmpli html"""
    <p>$(arg)</p>
  """
  let arg = true
  check a(arg).toString() == "<p>true</p>"

block:
  # json
  proc a(arg:JsonNode):Component = tmpli html"""
    <p>$(arg)</p>
  """
  let arg = %"aaa"
  check a(arg).toString() == "<p>aaa</p>"

block:
  # json
  proc a(arg:JsonNode):Component = tmpli html"""
    <p>$(arg)</p>
  """
  let arg = %"<script>alert('hello')</script>"
  check a(arg).toString() == "<p>&lt;script&gt;alert('hello')&lt;/script&gt;</p>"

block:
  # component
  proc a():Component = tmpli html"""
    <p>aaa</p>
  """

  proc b(arg:Component):Component = tmpli html"""
    <div>$(arg)</div>
  """
  let arg = a()
  check b(arg).toString() == "<div><p>aaa</p></div>"

block:
  let style = styleTmpl(Css, """
    .className{
      color: red;
    }
  """)
  let className = style.element("className")

  let expanded = fmt("""
    .[className]{
      color: red;
    }
  """, '[', ']')
  check $style == expanded

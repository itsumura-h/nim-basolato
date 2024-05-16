discard """
  cmd: "nim c -r $file"
  matrix: "; -d:httpbeast"
"""

import std/unittest
include ../src/basolato/core/templates


block:
  let str = "123$("
  #             | next position
  var point = 0
  var resStr = ""
  let blockType = identifyBlockType(str, point)
  echo blockType
  (point, resStr) = findStrBlock(str, point)
  echo point
  echo resStr
  check point == 3
  check resStr == "123"

block:
  echo "===================="
  let str = "$(str)aaa"
  #                | next position
  var point = 0
  var resStr = ""
  let blockType = identifyBlockType(str, point)
  echo blockType
  (point, resStr) = findNimVariableBlock(str, point)
  echo point
  echo resStr
  check point == 6
  check resStr == "str"

block:
  echo "===================="
  let str = "$if isActive {active}"
  #                        | next position
  var point = 0
  var resStr = ""
  let blockType = identifyBlockType(str, point)
  echo blockType
  (point, resStr) = findNimBlock(str, point)
  echo point
  echo resStr
  check point == 14
  check resStr == "if isActive "

block:
  echo "===================="
  let str = "$elif isActive {active}"
  #                          | next position
  var point = 0
  var resStr = ""
  let blockType = identifyBlockType(str, point)
  echo blockType
  (point, resStr) = findNimBlock(str, point)
  echo point
  echo resStr
  check point == 16
  check resStr == "elif isActive "

block:
  echo "===================="
  let str = "$else {active}"
  #                 | next position
  var point = 0
  var resStr = ""
  let blockType = identifyBlockType(str, point)
  echo blockType
  (point, resStr) = findNimBlock(str, point)
  echo point
  echo resStr
  check point == 7
  check resStr == "else "

block:
  echo "===================="
  let str = "{active}aaa"
  #                  | next position
  var point = 1
  var resStr = ""
  let blockType = identifyBlockType(str, point)
  echo blockType
  (point, resStr) = findStrBlock(str, point)
  echo point
  echo resStr
  check point == 8
  check resStr == "active"

block:
  echo "===================="
  let str = "${ let user = userOpt.get }aa"
  #                                     | next position
  var point = 0
  var resStr = ""
  let blockType = identifyBlockType(str, point)
  echo blockType
  (point, resStr) = findNimCodeBlock(str, point)
  echo point
  echo resStr
  check point == 27
  check resStr == " let user = userOpt.get "


block:
  echo "===================="
  proc view():Component =
    tmpl"""
      ${ let isActive = true }
      <!-- you're idiot -->
      $if isActive {
        active
      }$else{
        not active
      }
    """
  let res = view()
  echo res
  check $res == """<!-- you're idiot -->
      
        active"""


block:
  echo "===================="
  let msg = "Hello, world!"
  proc view():Component =
    tmpl"""
      <p>$(msg)</p>
    """
  let res = view()
  echo res
  check $res == "<p>Hello, world!</p>"


block:
  echo "===================="
  proc fn():string = return "hello func"
  proc view():Component =
    tmpl"""
      <p>$(fn())</p>
    """
  let res = view()
  echo res
  check $res == "<p>hello func</p>"


block:
  echo "===================="
  proc view():Component =
    let arr = @["a", "b", "c", "d", "e"]
    tmpl"""
      <ul>
        $for item in arr{
          <li>$(item)</li>
        }
      </ul>
    """
  let res = view()
  echo res
  check $res == """<ul>
        
          <li>a</li>
        
          <li>b</li>
        
          <li>c</li>
        
          <li>d</li>
        
          <li>e</li>
        
      </ul>"""


block:
  proc view():Component =
    tmpl"""
      $for i in 1..3{
        <script>
          const fn = (){
            alert("hello")
          }
          f()
        </script>
      }
    """
  let res = view()
  echo res
  check $res == """<script>
          const fn = (){
            alert("hello")
          }
          f()
        </script>
      
        <script>
          const fn = (){
            alert("hello")
          }
          f()
        </script>
      
        <script>
          const fn = (){
            alert("hello")
          }
          f()
        </script>"""

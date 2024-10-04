discard """
  cmd: "nim c $file"
"""
# nim c -r -d:test test_templates.nim

import std/unittest
include ../src/basolato/core/templates


suite("identifyBlockType"):
  test("findStrBlock"):
    let str = "123$("
    #             | next position
    var point = 0
    var resStr = ""
    let blockType = identifyBlockType(str, point)
    echo blockType
    check blockType == strBlock
    (point, resStr) = findStrBlock(str, point)
    echo point
    echo resStr
    check point == 3
    check resStr == "123"


  test("findNimVariableBlock"):
    let str = "$(str)aaa"
    #                | next position
    var point = 0
    var resStr = ""
    let blockType = identifyBlockType(str, point)
    echo blockType
    check blockType == displayVariableBlock
    (point, resStr) = findNimVariableBlock(str, point)
    echo point
    echo resStr
    check point == 6
    check resStr == "str"


  test("findNimBlock if"):
    let str = "$if isActive {active}"
    #                        | next position
    var point = 0
    var resStr = ""
    let blockType = identifyBlockType(str, point)
    echo blockType
    check blockType == ifBlock
    (point, resStr) = findNimBlock(str, point)
    echo point
    echo resStr
    check point == 14
    check resStr == "if isActive "


  test("findNimBlock elif"):
    let str = "$elif isActive {active}"
    #                          | next position
    var point = 0
    var resStr = ""
    let blockType = identifyBlockType(str, point)
    echo blockType
    check blockType == elifBlock
    (point, resStr) = findNimBlock(str, point)
    echo point
    echo resStr
    check point == 16
    check resStr == "elif isActive "


  test("findNimBlock else"):
    let str = "$else {active}"
    #                 | next position
    var point = 0
    var resStr = ""
    let blockType = identifyBlockType(str, point)
    echo blockType
    check blockType == elseBlock
    (point, resStr) = findNimBlock(str, point)
    echo point
    echo resStr
    check point == 7
    check resStr == "else "


  test("findNimBlock when"):
    let str = "$when defined(release){active}"
    #                                         | next position
    var point = 0
    var resStr = ""
    let blockType = identifyBlockType(str, point)
    echo blockType
    check blockType == whenBlock
    (point, resStr) = findNimBlock(str, point)
    echo point
    echo resStr
    check point == 23
    check resStr == "when defined(release)"


  test("findStrBlock after if block"):
    let str = "{active}aaa"
    #                  | next position
    var point = 1
    var resStr = ""
    let blockType = identifyBlockType(str, point)
    echo blockType
    check blockType == strBlock
    (point, resStr) = findStrBlock(str, point)
    echo point
    echo resStr
    check point == 8
    check resStr == "active"


  test("findNimCodeBlock"):
    let str = "${ let user = userOpt.get }aa"
    #                                     | next position
    var point = 0
    var resStr = ""
    let blockType = identifyBlockType(str, point)
    echo blockType
    check blockType == nimCodeBlock
    (point, resStr) = findNimCodeBlock(str, point)
    echo point
    echo resStr
    check point == 27
    check resStr == " let user = userOpt.get "


suite("parseTemplate"):
  test("nimblock, if"):
    proc view():Component =
      tmpl"""
        ${ let isActive = true }
        <!-- this is comment -->
        $if isActive {
          active
        }$else{
          not active
        }
      """
    let res = view()
    echo res
    check $res == """<!-- this is comment -->
        
          active"""


  test("display nim variable"):
    let msg = "Hello, world!"
    proc view():Component =
      tmpl"""
        <p>$(msg)</p>
      """
    let res = view()
    echo res
    check $res == "<p>Hello, world!</p>"


  test("display nim variable without escape"):
    let msg = "<p>Hello, world!</p>"
    proc view():Component =
      tmpl"""
        <div>$(msg|raw)</div>
      """
    let res = view()
    echo res
    check $res == "<div><p>Hello, world!</p></div>"


  test("call nim funcion"):
    proc fn():string = return "hello func"
    proc view():Component =
      tmpl"""
        <p>$(fn())</p>
      """
    let res = view()
    echo res
    check $res == "<p>hello func</p>"


  test("for display variable"):
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


  test("for javascript block"):
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


  test("invalid display variable"):
    let str ="<p>$msg</p>"

    expect Exception:
      discard identifyBlockType(str, 3)

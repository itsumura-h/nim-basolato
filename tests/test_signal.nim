discard """
  cmd: "nim c -d:test $file"
"""
# nim c -r -d:test test_signal.nim

import std/unittest
import basolato/view

suite("test signal"):
  test("crate signal"):
    let userSignal = createSignal((isLogin:true, name: "John", email: "john@example.com"))
    let user = userSignal.value()
    check user.isLogin == true
    check user.name == "John"
    check user.email == "john@example.com"

  test("set signal"):
    let userSignal = createSignal((isLogin:false, name: "", email: ""))
    var user = userSignal.value()
    check user.isLogin == false
    check user.name == ""
    check user.email == ""
    
    userSignal.value = (isLogin:true, name: "John", email: "john@example.com")
    user = userSignal.value()
    check user.isLogin == true
    check user.name == "John"
    check user.email == "john@example.com"

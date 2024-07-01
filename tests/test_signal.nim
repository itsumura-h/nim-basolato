discard """
  cmd: "nim c -d:test $file"
"""
# nim c -r -d:test test_signal.nim

import std/unittest
import basolato/view

suite("test signal"):
  test("crate signal"):
    let userSignal = createSignal((isLogi:true, name: "John", email: "john@example.com"))
    check userSignal.get().name == "John"
    check userSignal.get().email == "john@example.com"

  test("set signal"):
    let userSignal = createSignal((isLogin:false, name: "", email: ""))
    check userSignal.get().isLogin == false
    check userSignal.get().name == ""
    check userSignal.get().email == ""
    
    userSignal.set((isLogin:true, name: "John", email: "john@example.com"))
    check userSignal.get().isLogin == true
    check userSignal.get().name == "John"
    check userSignal.get().email == "john@example.com"

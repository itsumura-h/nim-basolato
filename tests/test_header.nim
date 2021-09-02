import unittest, tables, httpcore, strformat
from strutils import join
import ../src/basolato/core/base
include ../src/basolato/core/header

block:
  let header = [
    ("a", @["a", "b"])
  ].newHttpHeaders()
  check header.table["a"][0] == "a"
  check header.table["a"][1] == "b"

block:
  let header = newHttpHeaders()
  header.setDefaultHeaders()
  check header["server"] == fmt"Nim/{NimVersion}; Basolato/{BasolatoVersion}"

block:
  let header = newHttpHeaders()
  header.add("a", "a")
  check header["a"] == "a"
  header.add("a", "b")
  check header.table["a"][1] == "b"

block:
  let header1 = newHttpHeaders()
  header1.add("a", "a")
  let header2 = newHttpHeaders()
  header2.add("b", "b")
  let header = header1 & header2
  check header["a"] == "a"
  check header["b"] == "b"

block:
  let header1 = newHttpHeaders()
  header1.add("a", "a")
  let header2 = newHttpHeaders()
  header2.add("b", "b")
  header1 &= header2
  check header1["a"] == "a"
  check header1["b"] == "b"

block:
  var header = newHttpHeaders()
  header.add("a", "a")
  header.add("a", "b")
  header.add("date", "data1")
  header.add("date", "data2")
  header.add("set-cookie", "cookie1")
  header.add("set-cookie", "cookie2")
  header = header.format()
  check header["a"] == "a, b"
  check header.table["date"].len == 1
  check header.table["set-cookie"][0] == "cookie1"
  check header.table["set-cookie"][1] == "cookie2"

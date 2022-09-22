import unittest, tables, httpcore, strformat
from strutils import join
import ../src/basolato/core/base
import ../src/basolato/core/security/cookie
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
  var headers = newHttpHeaders()
  headers.add("a", "a")
  headers.add("a", "b")
  headers.add("set-cookie", Cookie.new("key1", "val1").toCookieStr())
  headers.add("set-cookie", Cookie.new("key2", "val2").toCookieStr())
  check headers.values("A") == @["a", "b"]
  check headers.values("Set-Cookie")[0].contains("key1=val1")
  check headers.values("Set-Cookie")[1].contains("key2=val2")
  echo headers.format()

block:
  var headers = newHttpHeaders()
  headers.add("date", "date1")
  headers.add("date", "date2")
  let headerStr = headers.format()
  check headerStr == "date: date1"

block:
  var header1 = {
    "Cache-Control": @["no-cache"],
    "Access-Control-Allow-Origin": @["http://localhost:3000", "http://localhost:3001"],
  }.newHttpHeaders()

  var header2 = {
    "Access-Control-Allow-Credentials": @["true"],
    "Access-Control-Allow-Origin": @["http://localhost:3001", "http://localhost:3002"],
  }.newHttpHeaders()

  var expected = {
    "Cache-Control": @["no-cache"],
    "Access-Control-Allow-Credentials": @["true"],
    "Access-Control-Allow-Origin": @["http://localhost:3000", "http://localhost:3001", "http://localhost:3002"],
  }.newHttpHeaders()

  header1 &= header2

  check header1 == expected

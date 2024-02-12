discard """
  cmd: "nim c -r $file"
"""

import std/unittest
import std/strformat
import std/httpclient
import std/strutils


const HOST = "http://0.0.0.0:5000"

block:
  let client = newHttpClient()
  let response = client.getContent(&"{HOST}/renderStr")
  check response == "test"

block:
  let client = newHttpClient()
  let response = client.getContent(&"{HOST}/renderHtml")
  check response.strip == "<h1>test</h1>"

block:
  let client = newHttpClient()
  let response = client.getContent(&"{HOST}/renderTemplate")
  check response.splitLines()[0] == "<h1>test template</h1>"

block:
  let client = newHttpClient()
  let response = client.getContent(&"{HOST}/renderJson")
  check response == """{"key":"test"}"""

block:
  let client = newHttpClient()
  let response = client.get(&"{HOST}/status500")
  check response.code() == Http500

block:
  let client = newHttpClient()
  let response = client.get(&"{HOST}/status500json")
  check response.code() == Http500

block:
  let client = newHttpClient(maxRedirects=0)
  let response = client.get(&"{HOST}/redirect")
  check response.headers["location"] == "/new_url"
  check response.code() == Http303

block:
  let client = newHttpClient(maxRedirects=0)
  let response = client.get(&"{HOST}/error-redirect")
  check response.headers["location"] == "/new_url"
  check response.code() == Http302

block:
  let client = newHttpClient(maxRedirects=0)
  let response = client.get(&"{HOST}/redirect-with-header")
  check response.headers["location"] == "/new_url"
  check response.headers["key"] == "value"
  check response.code() == Http303

block:
  let client = newHttpClient(maxRedirects=0)
  let response = client.get(&"{HOST}/error-redirect-with-header")
  check response.headers["location"] == "/new_url"
  check response.headers["key"] == "value"
  check response.code() == Http302

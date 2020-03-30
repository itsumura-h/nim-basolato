import unittest, strformat, strutils, httpclient, htmlparser, xmltree

include ../resources/layouts/application

proc assertSelect(response:httpclient.Response, elm:string): seq[XmlNode] =
  var html = parseHtml(response.body())
  var s = newSeq[XmlNode]()
  html.findAll(elm, s)
  var r = newSeq[XmlNode](s.len())
  for i, v in s:
    r[i] = v
  return r

const HOST = "http://0.0.0.0:5000"

suite "StaticPagesControllerTest":
  setup:
    var client = newHttpClient()
    var baseTitle = "Ruby on Rails Tutorial Sample App"

  test "should get home":
    var response = client.get(&"{HOST}")
    echo response.code()
    check response.code() == Http200
    check response.assertSelect("title")[0].innerText == &"{baseTitle}"

  test "should get help":
    var response = client.get(&"{HOST}/help")
    echo response.code()
    check response.code() == Http200
    check response.assertSelect("title")[0].innerText == &"Help | {baseTitle}"

  test "should get about":
    var response = client.get(&"{HOST}/about")
    echo response.code()
    check response.code() == Http200
    check response.assertSelect("title")[0].innerText == &"About | {baseTitle}"

  test "should get contact":
    var response = client.get(&"{HOST}/contact")
    echo response.code()
    check response.code() == Http200
    check response.assertSelect("title")[0].innerText == &"Contact | {baseTitle}"

suite "SiteLayoutTest":
  setup:
    var client = newHttpClient()

  test "layout links":
    var response = client.get(&"{HOST}")
    let aTags = response.assertSelect("a")
    var root, help, about, contact = 0
    for aTag in aTags:
      if contains($aTag, "href=\"/\""): root.inc()
      if contains($aTag, "href=\"/help\""): help.inc()
      if contains($aTag, "href=\"/about\""): about.inc()
      if contains($aTag, "href=\"/contact\""): contact.inc()
    check root == 2
    check help == 1
    check about == 1
    check contact == 1

    response = client.get(&"{HOST}/contact")
    let titleTag = response.assertSelect("title")[0]
    check titleTag.innerText == fullTitle("Contact")
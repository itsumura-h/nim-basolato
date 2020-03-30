import unittest, strformat, httpclient, htmlparser, xmltree

proc assertSelect(response:Response, elm:string): seq[string] =
  var html = parseHtml(response.body())
  var s = newSeq[XmlNode]()
  html.findAll(elm, s)
  var r = newSeq[string](s.len())
  for i, v in s:
    r[i] = v.innerText()
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
    check response.assertSelect("title")[0] == &"Home | {baseTitle}"

  test "should get help":
    var response = client.get(&"{HOST}/static_pages/help")
    echo response.code()
    check response.code() == Http200
    check response.assertSelect("title")[0] == &"Help | {baseTitle}"

  test "should get about":
    var response = client.get(&"{HOST}/static_pages/about")
    echo response.code()
    check response.code() == Http200
    check response.assertSelect("title")[0] == &"About | {baseTitle}"


import httpclient, htmlparser, xmltree

proc assertSelect*(response:httpclient.Response, elm:string): seq[XmlNode] =
  var html = parseHtml(response.body())
  var s = newSeq[XmlNode]()
  html.findAll(elm, s)
  var r = newSeq[XmlNode](s.len())
  for i, v in s:
    r[i] = v
  return r

import httpclient, uri, htmlparser, xmltree

proc formpost*(client:var HttpClient, url:string, data:openArray[tuple[key, value:string]]):Response =
  client.headers = newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"})
  return client.post(url, body=data.encodeQuery())

proc assertSelect*(response:httpclient.Response, elm:string): seq[XmlNode] =
  var html = parseHtml(response.body())
  var s = newSeq[XmlNode]()
  html.findAll(elm, s)
  var r = newSeq[XmlNode](s.len())
  for i, v in s:
    r[i] = v
  return r

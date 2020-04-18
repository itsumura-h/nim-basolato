import httpclient, uri


proc formpost*(client:var HttpClient, url:string, data:openArray[tuple[key, value:string]]):Response =
  client.headers = newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"})
  return client.post(url, body=data.encodeQuery())

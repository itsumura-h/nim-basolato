import httpclient, strformat

proc toBody(body:openarray[tuple[key, value:string]]):string =
  result = ""
  for row in body:
    if result.len == 0:
      result.add(&"{row.key}={row.value}")
    else:
      result.add(&"&{row.key}={row.value}")

proc formpost*(client:var HttpClient, url:string, data:openArray[tuple[key, value:string]]):Response =
  client.headers = newHttpHeaders({"Content-Type": "application/x-www-form-urlencoded"})
  return client.post(url, body=data.toBody())

import json, asyncdispatch

# checkSessionIdValid: proc(sessionId:string):Future[bool]

type ISessionDb* = tuple
  getToken: proc():Future[string]
  setStr: proc(key, value: string):Future[void]
  setJson: proc(key:string, value: JsonNode):Future[void]
  isSome: proc(key:string):Future[bool]
  getStr: proc(key:string):Future[string]
  getJson: proc(key:string):Future[JsonNode]
  getRows: proc():Future[JsonNode]
  delete: proc(key:string):Future[void]
  destroy: proc():Future[void]
  updateCsrfToken: proc():Future[string]

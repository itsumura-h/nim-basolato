import json, asyncdispatch

# checkSessionIdValid: proc(sessionId:string):Future[bool]

type ISessionDb* = tuple
  getToken: proc():Future[string]
  setStr: proc(key, value: string):Future[void]
  setJson: proc(key:string, value: JsonNode):Future[void]
  some: proc(key:string):Future[bool]
  get: proc(key:string):Future[string]
  getRows: proc():Future[JsonNode]
  delete: proc(key:string):Future[void]
  destroy: proc():Future[void]
  updateNonce: proc():Future[void]

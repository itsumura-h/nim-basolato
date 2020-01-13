import json, httpcore
# from jester import HttpCode

# export HttpCode

type
  Response* = ref object
    status*:HttpCode
    bodyString*: string
    bodyJson*: JsonNode
    responseType*: ResponseType
    headers*: seq[tuple[key, value:string]]
    url*: string

  ResponseType* = enum
    String
    Json
    Redirect

  CsrfError* = object of Exception
  Error404* = object of Exception

const basolatoVersion* = "v0.0.1"

import json, tables
import jester
export jester

type
  Response* = ref object
    status*:HttpCode
    bodyString*: string
    bodyJson*: JsonNode
    responseType*: ResponseType
    headers*: seq[tuple[key, value:string]]

  ResponseType* = enum
    String
    Json

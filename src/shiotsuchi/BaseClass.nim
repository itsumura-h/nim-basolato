import json, tables
import jester

type
  Response* = ref object
    status*:HttpCode
    bodyString*: string
    bodyJson*: JsonNode
    responseType*: ResponseType
    # headers*: seq[Table[string, string]]
    headers*: seq[tuple[key, value:string]]

  ResponseType* = enum
    Nil
    String
    Json

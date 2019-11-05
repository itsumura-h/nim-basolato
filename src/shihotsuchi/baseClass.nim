import json
import jester

type
  Response* = ref object
    status*:HttpCode
    bodyString*: string
    bodyJson*: JsonNode
    responseType*: ResponseType

  ResponseType* = enum
    Nil
    String
    Json

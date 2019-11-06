import json
import jester
import BaseClass
export BaseClass


# String
proc render*(body:string):Response =
  return Response(status:Http200, bodyString:body, responseType:String)

proc render*(status:HttpCode, body:string):Response =
  return Response(status:status, bodyString:body, responseType:String)


# Json
proc render*(body:JsonNode):Response =
  return Response(status:Http200, bodyJson:body, responseType:Json)

proc render*(status:HttpCode, body:JsonNode):Response =
  return Response(status:status, bodyJson:body, responseType:Json)
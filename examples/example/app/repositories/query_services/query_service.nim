import json
import allographer/query_builder
import query_service_interface


type QueryService* = ref object

proc newQueryService*(): QueryService =
  return QueryService()


proc toInterface*(this:QueryService):IQueryService =
  return ()

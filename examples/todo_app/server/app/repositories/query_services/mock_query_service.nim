import json, options
import interface_implements
import query_service_interface


type MockQueryService* = ref object

proc newMockQueryService*():MockQueryService =
  return MockQueryService()

implements MockQueryService, IQueryService:
  proc getPostsByUserId(self:MockQueryService, id:int):seq[JsonNode] =
    return @[
      %*{"id":1, "title": "test1", "content": "test1", "is_finished": true},
      %*{"id":2, "title": "test2", "content": "test2", "is_finished": false},
    ]

  proc getPostById(self:MockQueryService, id:int):Option[JsonNode] =
    return some(%*{"id":1, "title": "test1", "content": "test1", "is_finished": true})

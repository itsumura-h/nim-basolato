import json, options
import query_service_interface


type MockQueryService* = ref object

proc newMockQueryService*():MockQueryService =
  return MockQueryService()


proc getPostsByUserId(self:MockQueryService, id:int):seq[JsonNode] =
  return @[
    %*{"id":1, "title": "test1", "content": "test1", "is_finished": true},
    %*{"id":2, "title": "test2", "content": "test2", "is_finished": false},
  ]

proc getPostByUserId(self:MockQueryService, id:int):Option[JsonNode] =
  return some(%*{"id":1, "title": "test1", "content": "test1", "is_finished": true})


proc toInterface*(self:MockQueryService):IQueryService =
  return (
    getPostsByUserId: proc(id:int):seq[JsonNode] = self.getPostsByUserId(id),
    getPostByUserId: proc(id:int):Option[JsonNode] = self.getPostByUserId(id)
  )

import json
import ../../http/query_service_interface


type MockQueryService* = ref object

proc newMockQueryService*():MockQueryService =
  return MockQueryService()


proc getPostsByUserId(this:MockQueryService, id:int):seq[JsonNode] =
  return @[
    %*{"id":1, "title": "test1", "content": "test1", "is_finished": true},
    %*{"id":2, "title": "test2", "content": "test2", "is_finished": false},
  ]

proc getPostByUserId(this:MockQueryService, id:int):JsonNode =
  return %*{"id":1, "title": "test1", "content": "test1", "is_finished": true}


proc toInterface*(this:MockQueryService):IQueryService =
  return (
    getPostsByUserId: proc(id:int):seq[JsonNode] = this.getPostsByUserId(id),
    getPostByUserId: proc(id:int):JsonNode = this.getPostByUserId(id)
  )

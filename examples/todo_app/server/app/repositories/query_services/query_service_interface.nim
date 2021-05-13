import json, options

type IQueryService* = tuple
  getPostsByUserId: proc(id:int):seq[JsonNode]
  getPostById: proc(id:int):Option[JsonNode]

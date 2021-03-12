import json, options

type IQueryService* = tuple
  getPostsByUserId: proc(id:int):seq[JsonNode]
  getPostByUserId: proc(id:int):Option[JsonNode]

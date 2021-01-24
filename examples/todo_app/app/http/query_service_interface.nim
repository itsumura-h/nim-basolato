import json
import ../repositories/query_services/query_service

type IQueryService* = ref object
  ctx: QueryService

proc newIQueryService*():IQueryService =
  return IQueryService(
    ctx:newQueryService()
  )

proc getPostsByUserId*(this:IQueryService, id:int):seq[JsonNode] =
  return this.ctx.getPostsByUserId(id)

proc getPostByUserId*(this:IQueryService, id:int):JsonNode =
  return this.ctx.getPostByUserId(id)

Query Service
===

`Query Service` is a type of procs that access database or API to **fetch** data.  
This design is based on [Command–query_separation](https://en.wikipedia.org/wiki/Command–query_separation)

`Repository` is created in correspondence with the `aggregate`. However, `query service` is independent of aggregation and includes all data acquisition processes.

## Controller
```nim
import options
import basolato/controller
import ../../di_container
import ../../repositories/query_services/query_service

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  let auth = await newAuth(request)
  let id = await(auth.get("id")).parseInt
  let posts = di.queryService.getPostsByUserId(id)
  return render(await indexView(auth, posts))

proc show*(request:Request, params:Params):Future[Response] {.async.} =
  let id = params.getInt("id")
  let post = di.queryService.getPostByUserId(id)
  if not post.isSome:
    raise newException(Error404, "Post not found")
  let auth = await newAuth(request)
  return render(await showView(auth, post.get))
```

## Query service interface
```nim
import json, options

type IQueryService* = tuple
  getPostsByUserId: proc(id:int):seq[JsonNode]
  getPostByUserId: proc(id:int):Option[JsonNode]
```

## Query service
```nim
import json, options
import allographer/query_builder
import query_service_interface


type QueryService* = ref object

proc newQueryService*():QueryService =
  return QueryService()


proc getPostsByUserId(this:QueryService, id:int):seq[JsonNode] =
  return rdb().table("posts").where("user_id", "=", $id).get()

proc getPostByUserId(this:QueryService, id:int):Option[JsonNode] =
  return rdb().table("posts").find(id)


proc toInterface*(this:QueryService):IQueryService =
  return (
    getPostsByUserId: proc(id:int):seq[JsonNode] = this.getPostsByUserId(id),
    getPostByUserId: proc(id:int):Option[JsonNode] = this.getPostByUserId(id)
  )
```

## DI Container
```nim
type DiContainer* = tuple
  queryService: IQueryService

proc newDiContainer():DiContainer =
  return (
    queryService: newQueryService().toInterface(),
  )

let di* = newDiContainer()
```

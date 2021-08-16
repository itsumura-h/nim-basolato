import asyncdispatch
import post_value_objects
import post_entity


type IPostRepository* = tuple
  store: proc(post:Post):Future[void]
  changeStatus: proc(id:PostId, status:bool):Future[void]
  destroy: proc(id:PostId):Future[void]
  update: proc(post:Post):Future[void]

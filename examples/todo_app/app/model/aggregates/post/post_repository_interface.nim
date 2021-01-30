import json
import post_entity
import ../../value_objects


type IPostRepository* = tuple
  store: proc(post:Post)
  changeStatus: proc(id:PostId, status:bool)
  destroy: proc(id:PostId)
  update: proc(post:Post)

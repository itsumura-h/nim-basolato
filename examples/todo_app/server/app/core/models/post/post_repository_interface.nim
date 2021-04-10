import value_objects
import post_entity


type IPostRepository* = tuple
  store: proc(post:Post)
  changeStatus: proc(id:PostId, status:bool)
  destroy: proc(id:PostId)
  update: proc(post:Post)

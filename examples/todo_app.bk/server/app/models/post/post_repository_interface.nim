import asyncdispatch
import post_value_objects
import post_entity


type IPostRepository* = tuple
  create: proc(post:Post):Future[void]
  getPostById: proc(postId:PostId):Future[Post]
  update: proc(post:Post):Future[void]
  destroy: proc(post:Post):Future[void]

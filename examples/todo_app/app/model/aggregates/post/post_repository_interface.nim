import json
import ../../value_objects


type IPostRepository* = tuple
  store: proc(userId:UserId,  title:PostTitle, content:PostContent)
  changeStatus: proc(id:PostId, status:bool)
  destroy: proc(id:PostId)
  update: proc(id:PostId, title:PostTitle, content:PostContent, isFinished:bool)

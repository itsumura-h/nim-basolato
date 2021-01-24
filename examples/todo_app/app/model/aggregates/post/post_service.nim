import ../value_objects
import post_entity
import post_repository_interface


type PostService* = ref object
  repository:IPostRepository


proc newPostService*():PostService =
  return PostService(
    repository:newIPostRepository()
  )

# user
import core/models/user/user_repository_interface
import repositories/user/user_rdb_repository
# post
import core/models/post/post_repository_interface
import repositories/post/post_rdb_repository
import core/models/post/post_query_service_interface
import repositories/post/post_query_service

type DiContainer* = tuple
  userRepository: IUserRepository
  postRepository: IPostRepository
  postQueryService: IPostQueryService

proc newDiContainer():DiContainer =
  return (
    userRepository: newUserRdbRepository().toInterface(),
    postRepository: newPostRdbRepository().toInterface(),
    postQueryService: newPostQueryService().toInterface(),
  )

let di* = newDiContainer()

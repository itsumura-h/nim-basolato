# user
import models/user/user_repository_interface
import data_stores/repositories/user/user_rdb_repository
# post
import models/post/post_repository_interface
import data_stores/repositories/post/post_rdb_repository
import usecases/post/post_query_service_interface
import data_stores/query_services/post/post_query_service

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

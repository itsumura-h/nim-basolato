# query service
import repositories/query_services/query_service_interface
import repositories/query_services/query_service
import repositories/query_services/mock_query_service
# user
import core/models/user/user_repository_interface
import repositories/user/user_rdb_repository
# post
import core/models/post/post_repository_interface
import repositories/post/post_rdb_repository

type DiContainer* = tuple
  queryService: IQueryService
  userRepository: IUserRepository
  postRepository: IPostRepository

proc newDiContainer():DiContainer =
  return (
    queryService: newQueryService().toInterface(),
    # queryService: newMockQueryService().toInterface(),
    userRepository: newUserRdbRepository().toInterface(),
    postRepository: newPostRdbRepository().toInterface(),
  )

let di* = newDiContainer()

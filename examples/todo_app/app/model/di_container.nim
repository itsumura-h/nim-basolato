# query service
import ../http/query_service_interface
import ../repositories/query_services/query_service
import ../repositories/query_services/mock_query_service
# user
import aggregates/user/user_repository_interface
import ../repositories/user/user_rdb_repository
# post
import aggregates/post/post_repository_interface
import ../repositories/post/post_rdb_repository
# circle
import aggregates/circle/circle_repository_interface
import ../repositories/circle/circle_rdb_repository

type DiContainer* = tuple
  queryService: IQueryService
  userRepository: IUserRepository
  postRepository: IPostRepository
  circleRepository: ICircleRepository

proc newDiContainer():DiContainer =
  return (
    queryService: newQueryService().toInterface(),
    # queryService: newMockQueryService().toInterface(),
    userRepository: newUserRdbRepository().toInterface(),
    postRepository: newPostRdbRepository().toInterface(),
    circleRepository: newCircleRepository().toInterface(),
  )

let di* = newDiContainer()

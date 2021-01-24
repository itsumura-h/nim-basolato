import ../repositories/query_services/query_service
import ../repositories/user/user_rdb_repository
import ../repositories/post/post_rdb_repository

type DiContainer* = tuple
  queryService: QueryService
  userRepository: UserRdbRepository
  postRepository: PostRdbRepository

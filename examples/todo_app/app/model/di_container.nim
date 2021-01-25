import ../repositories/user/user_rdb_repository
import ../repositories/post/post_rdb_repository

type DiContainer* = tuple
  # userRepository: UserRdbRepository
  postRepository: PostRdbRepository

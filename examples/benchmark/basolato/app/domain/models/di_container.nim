import fortune/repositories/fortune_rdb_repository
import world/repositories/world_rdb_repository

type DiContainer* = tuple
  fortuneRepository: FortuneRdbRepository
  worldRepository: WorldRdbRepository

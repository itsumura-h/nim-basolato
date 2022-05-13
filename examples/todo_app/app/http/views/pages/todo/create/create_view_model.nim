import json


type CreateViewModel* = ref object
  params:JsonNode
  errors:JsonNode
  statuses:seq[JsonNode]
  users:seq[JsonNode]

proc params*(self:CreateViewModel):JsonNode = self.params
proc errors*(self:CreateViewModel):JsonNode = self.errors
proc statuses*(self:CreateViewModel):seq[JsonNode] = self.statuses
proc users*(self:CreateViewModel):seq[JsonNode] = self.users

proc new*(
  _:type CreateViewModel,
  params, errors:JsonNode,
  statuses, users:seq[JsonNode]
):CreateViewModel =
  return CreateViewModel(
    params:params,
    errors:errors,
    statuses:statuses,
    users:users
  )

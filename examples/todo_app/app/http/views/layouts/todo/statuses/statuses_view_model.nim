import
  std/asyncdispatch,
  std/json,
  std/tables,
  ./status/status_view_model


type StatusesViewModel* = ref object
  statuses: OrderedTableRef[string, StatusViewModel]

proc statuses*(self:StatusesViewModel):OrderedTableRef[string, StatusViewModel] = self.statuses

proc new*(_:type StatusesViewModel, jsonStatuses, tasks:seq[JsonNode]):StatusesViewModel =
  for task in tasks:
    for status in jsonStatuses:
      if task["status"].getStr == status["name"].getStr:
        if not status.hasKey("tasks"):
          status["tasks"] = newJArray()
        status["tasks"].add(task)
        break

  var statuses = newOrderedTable[string, StatusViewModel](jsonStatuses.len)
  for i, status in jsonStatuses:
    let hasLeftItem = i != 0
    let hasRightItem = i != jsonStatuses.len-1
    statuses[status["name"].getStr] = StatusViewModel.new(
      status["id"].getInt,
      status["name"].getStr,
      status["tasks"].getElems,
      hasLeftItem,
      hasRightItem
    )

  return StatusesViewModel(statuses:statuses)

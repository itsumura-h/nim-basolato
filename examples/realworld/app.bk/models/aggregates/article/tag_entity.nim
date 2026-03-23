import ../../vo/tag_id
import ../../vo/tag_name

type Tag* = object
  id*: TagId
  name*: TagName

proc new*(_:type Tag, name:TagName): Tag =
  let id = name.toId()
  return Tag(
    id: id,
    name: name
  )


proc new*(_:type Tag, name:string): Tag =
  let name = TagName.new(name)
  let id = name.toId()
  return Tag(
    id: id,
    name: name
  )

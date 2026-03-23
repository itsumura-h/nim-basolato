import ../../vo/tag_id
import ../../vo/tag_name

type Tag* = object
  id*: TagId
  name*: TagName

proc new*(_: type Tag, name: TagName): Tag =
  return Tag(
    id: name.toId(),
    name: name,
  )

proc new*(_: type Tag, name: string): Tag =
  return Tag.new(TagName.new(name))

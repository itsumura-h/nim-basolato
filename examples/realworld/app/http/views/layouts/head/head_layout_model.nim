type HeadLayoutModel* = object
  title*:string

proc new*(_:type HeadLayoutModel, title:string):HeadLayoutModel =
  let title = "Conduit - " & title
  return HeadLayoutModel(title: title)

type HeadLayoutModel* = object
  title*:string

proc new*(_:type HeadLayoutModel, title:string):HeadLayoutModel =
  return HeadLayoutModel(title:title)

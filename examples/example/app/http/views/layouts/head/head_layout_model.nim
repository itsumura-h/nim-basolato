type HeadLayoutModel* = object
  title*:string
  reload*:bool

proc new*(_:type HeadLayoutModel, title:string, reload=false):HeadLayoutModel =
  return HeadLayoutModel(title:title, reload:reload)

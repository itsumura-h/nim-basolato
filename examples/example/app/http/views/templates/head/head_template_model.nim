type HeadTemplateModel* = object
  title*:string

proc new*(_:type HeadTemplateModel, title:string):HeadTemplateModel =
  return HeadTemplateModel(title:title)

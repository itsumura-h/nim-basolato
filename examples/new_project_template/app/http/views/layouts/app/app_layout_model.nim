import ../head/head_layout_model


type AppLayoutModel* = object
  headLayoutModel*:HeadLayoutModel

proc new*(_:type AppLayoutModel, headLayoutModel:HeadLayoutModel):AppLayoutModel =
  return AppLayoutModel(headLayoutModel:headLayoutModel)

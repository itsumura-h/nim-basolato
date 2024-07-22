import ../../../../../../../src/basolato/view

type LoginUser* = object
  isLogin*:bool
  name*:string

type LoginTemplateModel* = object
  params*:Params
  errors*:seq[string]
  loginUser*:LoginUser

import jester, strutils

# フレームワーク
type
  Response = ref object
    status:HttpCode
    body: string


type
  BaseController = ref object of RootObj

proc httpResponse(this:BaseController, httpCode:HttpCode, body:string):Response =
  return Response(status:httpCode, body:body)


template response(response:Response) =
  resp response.status, response.body


# 実装
type
  RootController = ref object of BaseController

proc root(this:RootController, idArg:string):Response =
  let id = idArg.parseInt
  if id mod 2 == 0:
    return this.httpResponse(Http200, $id)
  else:
    return this.httpResponse(Http500, $id)


routes:
  get "/@id":
    response(RootController().root(@"id"))

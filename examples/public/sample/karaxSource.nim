include karax / prelude
import page1, page2

proc createDom(data: RouterData): VNode =
  case $(data.hashPart):
  of "#page1":
    result = page1.createDom()
  of "#page2":
    result = page2.createDom()

setRenderer createDom
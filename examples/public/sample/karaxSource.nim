include karax / prelude
from page1 import createDom
from page2 import createDom

proc createDom(data: RouterData): VNode =
  case $(data.hashPart):
  of "#page1":
    result = page1.createDom()
  of "#page2":
    result = page2.createDom()

setRenderer createDom
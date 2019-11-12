include karax / prelude
from page1 import render
from page2 import render

proc createDom(data: RouterData): VNode =
  case $(data.hashPart):
  of "#page1":
    result = page1.render()
  of "#page2":
    result = page2.render()

setRenderer createDom
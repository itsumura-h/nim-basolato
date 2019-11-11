include karax/prelude
import karax/vdom
import karax/karaxdsl

proc createDom(): VNode =
  result = buildHtml(tdiv):
    text "Hello World!"

  result = buildHtml(tdiv):
    ui:
      li: text "a"
      li: text "b"

setRenderer createDom
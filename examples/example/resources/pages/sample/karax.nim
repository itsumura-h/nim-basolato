import karax / [karaxdsl, vdom]
from sugar import `=>`

const places = @["boston", "cleveland", "los angeles", "new orleans"]

proc karaxHtml*(): string =
  let vnode = buildHtml(tdiv(class = "mt-3")):
    a(href="/"): text("back")
    h1: text("My Web Page")
    p: text("Hello world")
    ul:
      for place in places:
        li: text(place)
    dl:
      dt: text "Can I use Karax for client side single page apps?"
      dd: text "Yes"

      dt: text "Can I use Karax for server side HTML rendering?"
      dd: text "Yes"

  return $vnode

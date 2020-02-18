import karax / [karaxdsl, vdom]

const places = @["boston", "cleveland", "los angeles", "new orleans"]

proc karaxHtml*(): string =
  let vnode = buildHtml(tdiv(class = "mt-3")):
    a(href="/"): text("back")
    h1: text("My Web Page")
    p: text("Hello world")
    ul:
      for place in places:
        li: text(place)

  return $vnode

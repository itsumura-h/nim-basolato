import karax / [karaxdsl, vdom]

import json
import ../../../src/basolato/view
import ../base

proc editHtmlImpl(id:int, title:string, text:string, errors:JsonNode):string =
  let vnode = buildHtml(tdiv):
    h2: text("Edit Post")
    form("method"="post"):
      csrfTokenKarax()
      tdiv:
        p: text("Title")
        if errors.hasKey("title"):
          ul:
            for row in errors["title"]:
              li: text(row.get)
        p: input(type="text", "value"=title, name="title")
      tdiv:
        p: text("Text")
        if errors.hasKey("text"):
          ul:
            for row in errors["text"]:
              li: text(row.get)
        textarea(name="text"): text(text)
      button(type="submit"): text("create")
  return $vnode

proc editHtml*(auth:Auth, id:int, title="", text="", errors=newJObject()):string =
  baseHtml(auth, editHtmlImpl(id, title, text, errors))
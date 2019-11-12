import json
include karax / prelude
from sugar import `=>`

# var text1, text2 = ""
# var list:seq[tuple[key, value:string]] = @[]

var state = %*{
  "text1": "",
  "text2": "",
  "list": @[]
}


# =========================================================================
proc mounted() =
  echo "コンストラクタ1"

proc getText(id:string) =
  echo "Page1 getText"
  state[id] = %*($(getVNodeById(id).text))

proc addList() =
  echo "Page1 addList"
  if state["text1"].getStr.len() > 0 and state["text2"].getStr.len() > 0:
    state["list"].add(
      %*{"key": state["text1"].getStr, "value": state["text2"].getStr}
    )

proc resetList() =
  echo "Page1 resetList"
  state["list"] = %* @[]

# =========================================================================
mounted()
proc render*(): VNode =
  echo "render page1"
  echo state
  result = buildHtml(tdiv):
    p:
      a(href="/sample/karax/#page2"):
        text "page2へ"
    p:
      a(href="/"):
        text "トップページへ"
    h1(class="uk-heading-divider"): text "Page 1"
    input(`type`="text", id="text1", 
      onchange = () => (getText("text1"))
    )
    input(`type`="text", id="text2",
      onchange = () => (getText("text2"))
    )
    tdiv(class="uk-button-group"):
      button(class="uk-button uk-button-default",
        onclick = () => (addList())
      ):
        text "送信"
      button(class="uk-button uk-button-default",
        onclick = () => (resetList())
      ):
        text "リセット"
    table(class="uk-table uk-table-hover"):
      for v in state["list"]:
        tr:
          td: text(v["key"].getStr)
          td: text(v["value"].getStr)

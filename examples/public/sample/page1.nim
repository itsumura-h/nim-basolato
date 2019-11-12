include karax / prelude
from sugar import `=>`

var text1, text2 = ""
var list:seq[tuple[key, value:string]] = @[]

# =========================================================================
proc init() =
  echo "コンストラクタ"

proc getText(id:string, target:var string) =
  target = $(getVNodeById(id).text)

proc addList() =
  if text1.len() > 0 and text2.len() > 0:
    list.add(
      (text1, text2)
    )

proc resetList() =
  list = @[]

# =========================================================================
init()
proc createDom*(): VNode =
  result = buildHtml(tdiv):
    p:
      a(href="/sample/karax/#page2"):
        text "page2へ"
    p:
      a(href="/"):
        text "トップページへ"
    h1(class="uk-heading-divider"): text "Page 1"
    input(`type`="text", id="input1",
      onchange = () => getText("input1", text1)
    )
    input(`type`="text", id="input2",
      onchange = () => getText("input2", text2)
    )
    tdiv(class="uk-button-group"):
      button(class="uk-button uk-button-default", onclick=addList):
        text "送信"
      button(class="uk-button uk-button-default", onclick=resetList):
        text "リセット"
    table(class="uk-table uk-table-hover"):
      for v in list:
        tr:
          td: text(v.key)
          td: text(v.value)

include karax / prelude
from sugar import `=>`


# =========================================================================
proc init() =
  echo "コンストラクタ"

proc getText(id:string, target:var string) =
  target = $(getVNodeById(id).text)
  echo target

proc addList(text1:string, text2:string, list:var seq[tuple[key, value:string]]) =
  if text1.len() > 0 and text2.len() > 0:
    list.add(
      (text1, text2)
    )

proc resetList(list:var seq[tuple[key, value:string]]) =
  list = @[]

# =========================================================================
init()
proc createDom*(): VNode =
  var text1, text2 = ""
  var list: seq[tuple[key, value:string]] = @[]

  result = buildHtml(tdiv):
    p:
      a(href="/sample/karax/#page1"):
        text "page1へ"
    p:
      a(href="/"):
        text "トップページへ"
    h1(class="uk-heading-divider"): text "Page 2"
    input(`type`="text", id="input1",
      onchange = () => getText("input1", text1)
    )
    input(`type`="text", id="input2",
      onchange = () => getText("input2", text2)
    )
    tdiv(class="uk-button-group"):
      button(class="uk-button uk-button-default",
        onclick= () => addList(text1, text2, list)
      ):
        text "送信"
      button(class="uk-button uk-button-default",
        onclick= () => resetList(list)
      ):
        text "リセット"
    table(class="uk-table uk-table-hover"):
      echo list
      for v in list:
        tr:
          td: text(v.key)
          td: text(v.value)

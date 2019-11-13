import json
include karax / prelude
from sugar import `=>`

from store import Page1

# proc getText1():Page1 =
#   echo "Page1 getText1"
#   state.text1 = $(getVNodeById("input1_page1").text)
#   echo state.text1
#   return state

# proc getText2():Page1 =
#   echo "Page1 getText2"
#   state.text2 = $(getVNodeById("input2_page1").text)
#   return state

# proc addList():Page1 =
#   echo "Page1 addList"
#   echo repr state
#   if state.text1.len() > 0 and state.text2.len() > 0:
#     state.list.add(
#       (state.text1, state.text2)
#     )
#     return state

# proc resetList():Page1 =
#   echo "Page1 resetList"
#   state.list = @[]
#   return state

# proc getList():seq[tuple[key, value:string]] =
#   return state.list


# =============================================================================

proc createDom*(): VNode =
  var state = Page1(name:"Page1")
  # echo state.name
  result = buildHtml(tdiv):
    p:
      a(href="/sample/karax/#page2"):
        text "to Page2"
    h1(class="uk-heading-divider"): text "Page 1"
    input(`type`="text"):
      proc onchange(ev: Event; n: VNode) =
        state.text1 = $(n.text)
    input(`type`="text"):
      proc onchange(ev: Event; n: VNode) =
        state.text2 = $(n.text)
    tdiv(class="uk-button-group"):
      button(class="uk-button uk-button-default"):
        text "add"
        proc onclick(ev: Event; n: VNode) =
          echo state.name
          if state.text1.len() > 0 and state.text2.len() > 0:
            state.list.add(
              (state.text1, state.text2)
            )
      button(class="uk-button uk-button-default"):
        text "reset"
        proc onclick(ev:Event, n:VNode) =
          state.list = @[]
    table(class="uk-table uk-table-hover"):
      for v in state.list:
        tr:
          td: text(v.key)
          td: text(v.value)


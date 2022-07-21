import
  std/asyncdispatch,
  std/json,
  ../../../../../../../src/basolato2/view,
  ../../layouts/application_view,
  ../../layouts/sample/with_script_layout/with_script_layout_view


proc impl():Future[Component] {.async.} =
  style "css", style:"""
    <style>
      .className {
      }
    </style>
  """

  tmpli html"""
    <div class="$(style.element("className"))">
      $(withScriptLayoutView().await)
    </div>
    $(style)
  """

proc withScriptView*():Future[string] {.async.} =
  let title = ""
  return $applicationView(title, impl().await)

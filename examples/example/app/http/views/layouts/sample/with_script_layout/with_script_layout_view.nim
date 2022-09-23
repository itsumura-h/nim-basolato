import
  std/asyncdispatch,
  std/json,
  ../../../../../../../../src/basolato/view,
  ./with_script_layout_view_model

const s = staticRead("./with_script_layout_script.js")

proc script():Component = tmpli html"""
${result.add(s)}
"""

proc withScriptLayoutView*():Future[Component] {.async.} =
  style "css", style:"""
    <style>
      .className {
      }
    </style>
  """

  tmpli html"""
    <div class="$(style.element("className"))">
      <p id="num"></p>
      <button type="button" onclick="addDom('num')">increment</button>
    </div>
    $(style)
    <script>
      $(script())
      window.addEventListener('load', ()=>{init('num')})
    </script>
  """

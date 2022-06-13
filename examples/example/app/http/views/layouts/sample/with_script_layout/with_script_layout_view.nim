import
  std/asyncdispatch,
  std/json,
  ../../../../../../../../src/basolato/view,
  ./with_script_layout_view_model

const script = staticRead("./with_script_layout_script.js")

proc withScriptLayoutView*():Future[string] {.async.} =
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
    $[style]
    <script>
      $[script]
      window.addEventListener('load', ()=>{init('num')})
    </script>
  """

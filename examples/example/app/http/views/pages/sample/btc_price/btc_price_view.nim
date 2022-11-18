import std/asyncdispatch
import std/json
import ../../../../../../../../src/basolato/view
import ../../../layouts/application_view

const style = staticRead("./style.scss") # ===== SCSSをロード
const script = staticRead("./btc_price_script.js")
# const script = staticRead("./test.js")

proc impl():Future[Component] {.async.} =
  let style = styleTmpl(Scss, style) # ===== SCSSをCSSにコンパイル

  tmpli html"""
    $style <!-- ===== HTMLにCSSを埋め込み -->
    <div class="$(style.element("className"))" id="$(style.element("id"))">
    </div>
    <button onclick="incrementNum()">Increment</button>
    <script>
      $script
      // document.addEventListener("alpine:init", mount("$(style.element("id"))"), false)
      document.addEventListener("alpine:init", mount("$(style.element("id"))"))
      // mount("$(style.element("id"))")
    </script>
  """

proc btcPriceView*():Future[string] {.async.} =
  let title = ""
  return $applicationView(title, impl().await)

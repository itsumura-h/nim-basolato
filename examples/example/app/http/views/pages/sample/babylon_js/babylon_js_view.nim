import json, asyncdispatch
import ../../../../../../../../src/basolato/view
import ../../../layouts/application_view

const babylonScript = staticRead("./babylon_script.js")

proc impl():Future[Component] {.async.} =
  let style = styleTmpl(Css, """
    <style>
      #renderCanvas {
        width   : 100%;
        height  : 100%;
        touch-action: none;
      }
    </style>
  """)

  tmpli html"""
  <main>
    <article>
      <a href="/">go back</a>
      <hr>
      $(style)
      <canvas id="renderCanvas"></canvas>
      <script src="https://preview.babylonjs.com/babylon.js"></script>
      <script>
        $babylonScript
        window.addEventListener('DOMContentLoaded', main);
      </script>
    </article>
  </main>
  """

proc babylonJsView*():Future[Component] {.async.} =
  let title = ""
  return applicationView(title, impl().await)

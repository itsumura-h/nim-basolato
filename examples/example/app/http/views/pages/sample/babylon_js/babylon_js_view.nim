import json, asyncdispatch
import ../../../../../../../../src/basolato/view
import ../../../layouts/application_view


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
      <script src="/js/nim-babylon.js"></script>
      <script src="https://preview.babylonjs.com/babylon.js"></script>
      <script src="https://code.jquery.com/pep/0.4.1/pep.js"></script>
      <script>
        window.addEventListener('DOMContentLoaded', main);
      </script>
    </article>
  </main>
  """

proc babylonJsView*():Future[string] {.async.} =
  let title = ""
  return $applicationView(title, impl().await)

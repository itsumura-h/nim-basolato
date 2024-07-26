import ../../../../../../../src/basolato/view


proc babylonJsPage*():Component =
  let style = styleTmpl(Css, """
    <style>
      #renderCanvas {
        width   : 100%;
        height  : 100%;
        touch-action: none;
      }
    </style>
  """)

  tmpl"""
  <main>
    <article>
      <a href="/">go back</a>
      <hr>
      $(style)
      <canvas id="renderCanvas"></canvas>
      <script defer src="https://preview.babylonjs.com/babylon.js"></script>
      <script defer src="/js/babylon_script.js"></script>
    </article>
  </main>
  """

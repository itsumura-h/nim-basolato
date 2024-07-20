import ../../../../../../../src/basolato/view


proc webSocketTemplate*():Component =
  let style = styleTmpl(Css, """
    <style>
      .iframe {
        height: 80vh;
      }
    </style>
  """)

  tmpl"""
    $(style)
    <main>
      <a href="/">go back</a>
      <section>
        <aside>
          <iframe src="/sample/web-socket-component" class="$(style.element("iframe"))"></iframe>
        </aside>
        <aside>
          <iframe src="/sample/web-socket-component" class="$(style.element("iframe"))"></iframe>
        </aside>
      </section>
    </main>
  """

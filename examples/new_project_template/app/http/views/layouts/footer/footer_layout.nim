import basolato/view


proc footerLayout*():Component =
  let style = styleTmpl(Css, """
    <style>
      .footer {
        background-color: gray;
      }
    </style>
  """)
  
  tmpl"""
    $(style)
    <footer class="$(style.element("footer"))">
      <div>
        <p>
          &copy; 2026 Basolato. All rights reserved.
        </p>
      </div>
    </footer>
  """

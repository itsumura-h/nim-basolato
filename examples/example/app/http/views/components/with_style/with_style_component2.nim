import ../../../../../../../src/basolato/view


proc withStyleComponent2*():Component =
  let style2 = styleTmpl(Css, """
    <style>
      .className{
        height: 200px;
        width: 200px;
        background-color: blue;
      }
      .className:hover{
        background-color: green;
      }
    </style>
  """)

  tmpl"""
    <div class="$(style2.element("className"))"></div>
    $(style2)
  """

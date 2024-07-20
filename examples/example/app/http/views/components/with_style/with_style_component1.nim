import ../../../../../../../src/basolato/view


proc withStyleComponent1*():Component =
  let style1 = styleTmpl(Css, """
    <style>
      .className{
        height: 200px;
        width: 200px;
        background-color: red;
      }
      .className:hover{
        background-color: blue;
      }
    </style>
  """)

  tmpl"""
    <div class="$(style1.element("className"))"></div>
    $(style1)
  """

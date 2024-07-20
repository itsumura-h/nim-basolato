import ../../../../../../../src/basolato/view


proc withStyleComponent3*():Component =
  let style3= styleTmpl(Scss, """
    <style>
      .className{
        height: 200px;
        width: 200px;
        background-color: yellow;
        
        &:hover{
          background-color: red;
        }
      }
    </style>
  """)

  tmpl"""
    <div class="$(style3.element("className"))"></div>
    $(style3)
  """

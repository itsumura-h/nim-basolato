import ../../../../../../../src/basolato/view
import ../../layouts/application_view


proc component1():Component =
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

  tmpli html"""
    $(style1)
    <div class="$(style1.element("className"))"></div>
  """


proc component2():Component =
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

  tmpli html"""
    $(style2)
    <div class="$(style2.element("className"))"></div>
  """

proc component3():Component =
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

  tmpli html"""
    $(style3)
    <div class="$(style3.element("className"))"></div>
  """

proc impl():Component = tmpli html"""
<main>
  <article>
    <a href="/">go back</a>
    $(component1())
    $(component2())
    $(component3())
  </article>
</main>
"""

proc withStyleView*():string =
  let title = ""
  return $applicationView(title, impl())

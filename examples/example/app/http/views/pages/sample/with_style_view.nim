import ../../../../../../../src/basolato/view
import ../../layouts/application_view


proc component1():string =
  style "css", style1:"""
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
  """

  tmpli html"""
    $<style1>
    <div class="$(style1.element("className"))"></div>
  """


proc component2():string =
  style "css", style2:"""
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
  """

  tmpli html"""
    $<style2>
    <div class="$(style2.element("className"))"></div>
  """

proc component3():string =
  style "scss", style3:"""
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
  """

  tmpli html"""
    $<style3>
    <div class="$(style3.element("className"))"></div>
  """

proc impl():string = tmpli html"""
$<component1()>
$<component2()>
$<component3()>
"""

proc withStyleView*():string =
  let title = ""
  return applicationView(title, impl())

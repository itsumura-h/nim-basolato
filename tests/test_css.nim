discard """
  cmd: "nim c -r $file"
"""

import unittest, json, strutils
include ../src/basolato/view


block:
  let style = styleTmpl(Scss, """
    <style>
      .className{
        height: 200px;
        width: 200px;
        background-color: red;

        &:hover{
          background-color: green;
        }
      }
    </style>
  """)
  echo style.body
  echo style.saffix

import ../../../../src/basolato/view

proc impl():string = tmpli html"""
login
"""

proc loginView*(this:View):string =
  return impl()

import os
import jester except redirect, setCookie
import base, cookie, session, auth
from private import render, redirect, errorRedirect, header

export jester except redirect, setCookie
export base, cookie, session, auth
export render, redirect, errorRedirect, header

proc html*(r_path:string):string =
  ## arg r_path is relative path from /resources/
  block:
    let path = getCurrentDir() & "/resources/" & r_path
    let f = open(path, fmRead)
    result = $(f.readAll)
    defer: f.close()
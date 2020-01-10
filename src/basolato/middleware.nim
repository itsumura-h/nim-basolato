import jester
import BaseClass
import routing
from controller import render

export jester, Response, render


template middleware*(procs:varargs[Response]) =
  for p in procs:
    if p == nil:
      echo getCurrentExceptionMsg()
    else:
      route(p)
      break

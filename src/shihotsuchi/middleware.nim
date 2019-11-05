import baseClass
import routing


template middleware*(procs:varargs[Response]) =
  for p in procs:
    if p == nil:
      echo getCurrentExceptionMsg()
    else:
      route(p)
      break

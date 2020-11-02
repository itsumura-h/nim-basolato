import os, httpcore, strformat
import resources/original_error_page

proc errorPage*(status:HttpCode, msg:string):string =
  when defined(release):
    try:
      let customNumberPath = getCurrentDir() / fmt"./resources/errors/{status.int}.html"
      let customGeneralPath = getCurrentDir() / "./resources/errors/error.html"
      let path =
        if fileExists(customNumberPath):
          customNumberPath
        elif fileExists(customGeneralPath):
          customGeneralPath
        else:
          raise newException(Exception, "")
      let errorPageView = open(path, fmRead).readAll()
      return errorPageView
    except:
      return originalErrorPage(status, msg)
  else:
    return originalErrorPage(status, msg)

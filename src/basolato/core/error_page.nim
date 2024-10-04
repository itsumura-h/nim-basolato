import std/httpcore
when defined(release):
  import std/os
  import std/strformat
import ./resources/original_error_page
import ./view


proc errorPage*(status:HttpCode, msg:string):string =
  when defined(release):
    try:
      let customNumberPath = getCurrentDir() / fmt"app/http/views/errors/{status.int}.html"
      let customGeneralPath = getCurrentDir() / "app/http/views/errors/error.html"
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
      return $(originalErrorPage(status, msg))
  else:
    return $originalErrorPage(status, msg)

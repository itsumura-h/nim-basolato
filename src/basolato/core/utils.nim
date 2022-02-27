import strutils, random

type
  SameSite* = enum
    None, Lax, Strict

func makeCookie*(key, value, expires: string, domain = "", path = "",
                 secure = false, httpOnly = false,
                 sameSite = Lax): string =
  result = ""
  result.add key & "=" & value
  if domain != "": result.add("; Domain=" & domain)
  if path != "": result.add("; Path=" & path)
  if expires != "": result.add("; Expires=" & expires)
  if secure: result.add("; Secure")
  if httpOnly: result.add("; HttpOnly")
  if sameSite != None:
    result.add("; SameSite=" & $sameSite)

func getOsName*():string =
  when defined(maxosx) or defined(linux) or defined(bsd):
    const f = staticRead("/etc/os-release")
    for row in f.split("\n"):
      let kv = row.split("=")
      if kv[0] == "ID":
        return kv[1]
  elif defined(windows):
    return "windows"
  else:
    return ""

proc randStr*(n:varargs[int]):string =
  randomize()
  let options = {'0','1','2','3','4','5','6','7','8','9',
    'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r',
    's','t','u','v','w','x','y','z',
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R',
    'S','T','U','V','W','X','Y','Z',
  }
  var n = n.sample()
  for _ in 1..n:
    add(result, options.sample())

# proc isExistsLibsass*():bool =
#   ## used in /view
#   when defined(macosx):
#     const query = "ldconfig -p | grep libsass"
#     const res = gorgeEx(query)
#     return res.exitCode == 0 and res.output.len > 0
#   elif defined(linux) or defined(bsd):
#     const osName = getOsName()
#     if osName == "alpine":
#       const query = "cat /lib/apk/db/installed | grep libsass"
#       const res = gorgeEx(query)
#       return res.exitCode == 0 and res.output.len > 0
#     elif ["ubuntu", "debian"].contains(osName):
#       const query = "ldconfig -p | grep libsass"
#       const res = gorgeEx(query)
#       return res.exitCode == 0 and res.output.len > 0
#     else:
#       raise newException(Exception, "The only supported OS of Linux are Alpine, Debian, and Ubuntu.")
#   elif defined(windows):
#     return false

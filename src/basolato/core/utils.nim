import strutils

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

func getOsName():string =
  const f = staticRead("/etc/os-release")
  for row in f.split("\n"):
    let kv = row.split("=")
    if kv[0] == "ID":
      return kv[1]

func isExistsLibsass*():bool =
  ## used in /view
  when defined(macosx):
    const query = "ldconfig -p | grep libsass"
    const res = gorgeEx(query)
    return res.exitCode == 0 and res.output.len > 0
  elif defined(linux) or defined(bsd):
    const osName = getOsName()
    if osName == "alpine":
      const query = "cat /lib/apk/db/installed | grep libsass"
      const res = gorgeEx(query)
      return res.exitCode == 0 and res.output.len > 0
    else: # Ubuntu/Debian/CentOS...
      const query = "ldconfig -p | grep libsass"
      const res = gorgeEx(query)
      return res.exitCode == 0 and res.output.len > 0
  else: # Windows
    const libDir = "/usr/lib /usr/local/lib"
    const libsass = "libsass.dll"
    const query = "find " & libDir & " -name \"" & libsass & "\""
    const res = gorgeEx(query)
    return res.exitCode == 0 and res.output.len > 0

# 3rd party
import templates, httpcore
# framework
import basolato/base
import basolato/view

proc errorPage*(status:HttpCode, msg:string): string =
  when defined(release):
    tmpli html("""
<html xmlns="http://www.w3.org/1999/xhtml">
  <head><title>$status</title></head>
  <body>
    <h1>$status</h1>
  </body>
</html>
""")
  else:
    tmpli html("""
<html xmlns="http://www.w3.org/1999/xhtml">
  <head><title>Basolato Dev Error Page</title></head>
  <body>
    <h1>$status</h1>
    <h2>An error has occured in one of your routes.</h2>
    <p><b>Detail: </b></p>
    <code><pre>$(msg)</pre></code>
    <hr>
    <p style="text-align: center;">👑Nim ⬟Basolato $(basolatoVersion)</p>
  </body>
</html>
""")

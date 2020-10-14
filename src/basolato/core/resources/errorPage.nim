#? stdtmpl | standard
#import httpcore
## framework
#from ../base import basolatoVersion
#proc errorPage*(status:HttpCode, msg:string): string =
  #when defined(release):
<html xmlns="http://www.w3.org/1999/xhtml">
  <head><title>$status</title></head>
  <body>
    <h1>$status</h1>
  </body>
</html>
  #else:
<html xmlns="http://www.w3.org/1999/xhtml">
  <head><title>Basolato Dev Error Page</title></head>
  <body>
    <h1>$status</h1>
    <h2>An error has occured in one of your routes.</h2>
    <p><b>Detail: </b></p>
    <code><pre>${msg}</pre></code>
    <hr>
    <p style="text-align: center;">👑Nim ${NimVersion} ⬟Basolato ${basolatoVersion}</p>
  </body>
</html>

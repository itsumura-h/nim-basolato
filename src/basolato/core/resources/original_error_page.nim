#? stdtmpl | standard
#import httpcore
## framework
#from ../base import BasolatoVersion
#proc originalErrorPage*(status:HttpCode, msg:string): string =
  #when defined(release):
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>$status</title>
  </head>
  <body>
    <h1>$status</h1>
  </body>
</html>
  #else:
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>Basolato Dev Error Page</title>
    <link rel="stylesheet", href="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@9.17.1/build/styles/ir-black.min.css"/>
    <script src="http://cdn.jsdelivr.net/gh/highlightjs/cdn-release@9.17.1/build/highlight.min.js"></script>
  </head>
  <body>
    <h1>$status</h1>
    <h2>An error has occured in one of your routes.</h2>
    <p><b>Detail: </b></p>
    <pre><code class="nimrod">${msg}</code></pre>
    <hr>
    <p style="text-align: center;">👑Nim ${NimVersion} ⬟Basolato ${BasolatoVersion}</p>
    <script>hljs.initHighlightingOnLoad();</script>
  </body>
</html>

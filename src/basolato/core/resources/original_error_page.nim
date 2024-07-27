import std/httpcore
import ../view
from ../base import BasolatoVersion

proc originalErrorPage*(status:HttpCode, msg:string): Component =
  let status = $status
  tmpl"""
    $when defined(release){
      <!DOCTYPE html>
        <head>
          <title>$(status)</title>
        </head>
        <body>
          <h1>$(status)</h1>
        </body>
      </html>
    }$else{
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Document</title>
          <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/ir-black.min.css">
          <script src="https://unpkg.com/@highlightjs/cdn-assets@11.9.0/highlight.min.js"></script>
        </head>
        <body>
          <h1>$(status)</h1>
          <h2>An error has occured in one of your routes.</h2>
          <p><b>Detail: </b></p>
          <pre><code class="nimrod">$(msg)</code></pre>
          <hr>
          <p style="text-align: center;">👑Nim $(NimVersion) ⬟Basolato $(BasolatoVersion)</p>
          <script>hljs.highlightAll();</script>
        </body>
      </html>
    }
  """

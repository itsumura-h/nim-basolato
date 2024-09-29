import std/httpcore
import ../view
from ../base import BasolatoVersion

proc originalErrorPage*(status:HttpCode, msg:string): Component =
  let status = $status
  tmpl"""
    $when defined(release){
      <body>
        <h1>$(status)</h1>
      </body>
    }$else{
      <body>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/prismjs@1.29.0/themes/prism-okaidia.min.css">
        <h1>$(status)</h1>
        <h2>An error has occured in one of your routes.</h2>
        <p><b>Detail: </b></p>
        <pre><code class="language-nim">$(msg)</code></pre>
        <hr>
        <p style="text-align: center;">👑Nim $(NimVersion) ⬟Basolato $(BasolatoVersion)</p>
        <script src="https://cdn.jsdelivr.net/npm/prismjs@1.29.0/components/prism-core.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/prismjs@1.29.0/plugins/autoloader/prism-autoloader.min.js"></script>
      </body>
    }
  """

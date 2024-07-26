#? stdtmpl | standard
#import std/httpcore
#from ../base import BasolatoVersion
#proc originalErrorPage*(status:HttpCode, msg:string): string =
  #when defined(release):
<!DOCTYPE html>
  <head>
    <title>$status</title>
  </head>
  <body>
    <h1>$status</h1>
  </body>
</html>
  #else:
<!DOCTYPE html>
  <head>
    <title>Basolato Dev Error Page</title>
    <!-- turbo -->
    <script type="module" src="https://unpkg.com/@hotwired/turbo@8.0.5/dist/turbo.es2017-esm.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/ir-black.min.css">
    <!-- highlight.js -->
    <script type="module">
      import { Controller, Application } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
      import hljs from 'https://unpkg.com/@highlightjs/cdn-assets@11.9.0/es/highlight.min.js';
    
      // https://saashammer.com/blog/use-stimulus-to-render-markdown-and-highlight-code-block/
      class HljsController extends Controller {
        static targets = [ "code" ]

        connect() {
          this.run();
        }
        
        run() {
          hljs.highlightElement(this.codeTarget)
        }
      }
    
      const application = Application.start()
      application.register("hljs", HljsController)
    </script>
  </head>
  <body>
    <h1>$status</h1>
    <h2>An error has occured in one of your routes.</h2>
    <p><b>Detail: </b></p>
    <pre data-controller="hljs"><code class="nimrod" data-hljs-target="code">${msg}</code></pre>
    <hr>
    <p style="text-align: center;">👑Nim ${NimVersion} ⬟Basolato ${BasolatoVersion}</p>
  </body>
</html>

#? stdtmpl | standard
#import ../base
#proc ddPage*(msg:string): string =
  <body>
    <link rel="stylesheet", href="https://unpkg.com/prismjs@1.29.0/themes/prism-okaidia.min.css"/>

    <style>
      html, body {
        height: 100%;
        margin: 0;
      }
      
      .wrap {
        display: flex;
        flex-direction: column;
        height: 100%;
      }
      
      pre {
        flex-grow: 1;
        overflow-y: auto;
        margin: 0;
      }
      
      .footer {
        height: 64px;
        flex-shrink: 0;
      }
      
      code {
        display: block;
        padding: 16px;
        white-space: pre-wrap;
      }
    </style>

    <div class="wrap">
      <pre><code class="language-nim">${msg}</code></pre>
      <div class="footer">
        <hr>
        <p style="text-align: center;">👑Nim ${NimVersion} ⬟Basolato ${BasolatoVersion}</p>
      </div>
    </div>

    <script src="https://unpkg.com/prismjs@1.29.0/components/prism-core.min.js"></script>
    <script src="https://unpkg.com/prismjs@1.29.0/plugins/autoloader/prism-autoloader.min.js"></script>
  </body>

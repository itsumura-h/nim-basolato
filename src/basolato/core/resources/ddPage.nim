#? stdtmpl | standard
#import strutils
## framework
#import ../base
#proc ddPage*(msg:string): string =
  <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>Basolato Display Valiable Page</title>
      <link rel="stylesheet", href="https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@9.17.1/build/styles/ir-black.min.css"/>
      <script src="http://cdn.jsdelivr.net/gh/highlightjs/cdn-release@9.17.1/build/highlight.min.js"></script>
      <style>
        body {
          max-height: 100vh;
        }
        .wrap {
          min-height: calc(100vh - 62px);
          position: relative;/*←相対位置*/
          padding-bottom: 62px;/*←footerの高さ*/
          box-sizing: border-box;/*←全て含めてmin-height:100vhに*/
        }
        footer {
          width: 100%;
          position: absolute;/*←絶対位置*/
          bottom: 0; /*下に固定*/
        }
        pre {
          /* 62px + 13(margin of pre) + 8(margin of body)*2 + 1 */
          height: calc(100vh - 92px);
        }
        code {
          height: 100%;
          overflow: auto;
        }
      </style>
    </head>
    <body>
      <div class="wrap">
        <pre><code class="nimrod">${msg.indent(2)}</code></pre>
        <footer>
          <hr>
          <p style="text-align: center;">👑Nim ${NimVersion} ⬟Basolato ${basolatoVersion}</p>
        </footer>
      </div>
      <script>hljs.initHighlightingOnLoad();</script>
    </body>
  </html>
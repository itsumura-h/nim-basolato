#? stdtmpl | standard
#import httpcore
## framework
#import base
#import strutils
#proc ddPage*(msg:string): string =
  <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <title>Basolato Display Valiable Page</title>
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
          background-color: black;
          color: white;
          overflow: auto;
        }
      </style>
    </head>
    <body>
      <div class="wrap">
        <code><pre>${msg.indent(2)}</pre></code>
        <footer>
          <hr>
          <p style="text-align: center;">👑Nim ⬟Basolato ${basolatoVersion}</p>
        </footer>
      </div>
    </body>
  </html>
  
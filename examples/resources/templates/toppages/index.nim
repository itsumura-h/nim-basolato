import templates

proc indexHtml*(): string = tmpli html"""
  <h1>Topppage</h1>
  <p><a href="/toppage/react/">react</a></p>
  <p><a href="/toppage/vue/">vue</a></p>
  <p><a href="/sample/">sample</a></p>
  <p><a href="/sample/checkLogin/">checkLogin</a></p>
  <p><a href="/sample/fib/30/">fib</a></p>
  <p><a href="/ManageUsers/">ManageUsers</a></p>
  <p><a href="/withHeader/middlewar_header/">ミドルウェアありヘッダーあり</a></p>
  <p><a href="/withHeader/header/">ミドルウェアなしヘッダーあり</a></p>
  <p><a href="/withHeader/middleware/">ミドルウェアありヘッダーなし</a></p>
  <p><a href="/withHeader/nothing/">ミドルウェアなしヘッダーなし</a></p>
  <p><a href="/withHeader/middlewar_header_json/">ミドルウェアありヘッダーありJson</a></p>
"""
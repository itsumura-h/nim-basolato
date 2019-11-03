import templates

proc indexHtml*(): string = tmpli html"""
  <h1>Topppage</h1>
  <p><a href="/toppage/react/">react</a></p>
  <p><a href="/toppage/vue/">vue</a></p>
  <p><a href="/sample/">sample</a></p>
  <p><a href="/sample/fib/30/">fib</a></p>
  <p><a href="/ManageUsers/">ManageUsers</a></p>
"""
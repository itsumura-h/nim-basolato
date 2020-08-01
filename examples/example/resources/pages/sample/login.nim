#? stdtmpl | standard
# #framework
# import json
# import basolato/view
#proc loginHtml*(auth:Auth, flash=newJObject()): string =
<a href="/">go back</a>
<div>
  #if auth.isLogin():
    #for key, val in flash:
      <p style="color: green">${val.get}</p>
    #end for
    <h1>Login Name: ${auth.get("name")}</h1>
    <form method="POST" action="/sample/logout">
      ${csrfToken()}
      <button type="submit">Logout</button>
    </form>
  #else:
    <form method="POST">
      ${csrfToken()}
      <input type="text" name="name" placeholder="name">
      <button type="submit">login</button>
    </form>
  #end if
</div>

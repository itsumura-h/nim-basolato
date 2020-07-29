View
===
[back](../README.md)

Table of Contents

<!--ts-->
   * [View](documents/view.md#view)
      * [Introduction](documents/view.md#introduction)
      * [Csrf Token](documents/view.md#csrf-token)
         * [nim-templates](documents/view.md#nim-templates)
         * [htmlgen](documents/view.md#htmlgen)
         * [SCF](documents/view.md#scf)
         * [Karax](documents/view.md#karax)
      * [Block components example](documents/view.md#block-components-example)
         * [nim-templates](documents/view.md#nim-templates-1)
         * [htmlgen](documents/view.md#htmlgen-1)
         * [SCF](documents/view.md#scf-1)
         * [Karax](documents/view.md#karax-1)
      * [old helper](documents/view.md#old-helper)
      * [Auth](documents/view.md#auth)

<!-- Added by: runner, at: Wed Jul 29 09:34:30 UTC 2020 -->

<!--te-->

## Introduction
There are 4 ways to render HTML in Basolato. Although each library has it's own benefits and drawbacks, every library can be used.  
Basolato use `nim-templates` as a default template engin. It can be used by importing `basolato/view`.

- [htmlgen](https://nim-lang.org/docs/htmlgen.html)
- [SCF](https://nim-lang.org/docs/filters.html)
- [Karax](https://github.com/pragmagic/karax)
- [nim-templates](https://github.com/onionhammer/nim-templates)

<table>
  <tr>
    <th>Library</th><th>Benefits</th><th>Drawbacks</th>
  </tr>
  <tr>
    <td>htmlgen</td>
    <td>
      <ul>
        <li>Nim standard library</li>
        <li>Easy to use for Nim programmer</li>
        <li>Available to define plural Procedures in one file</li>
      </ul>
    </td>
    <td>
      <ul>
        <li>Cannot use `if` statement and `for` statement</li>
        <li>Maybe difficult to collaborate with designer or markup enginner</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td>SCF</td>
    <td>
      <li>Nim standard library</li>
      <li>Available to use `if` statement and `for` statement</li>
      <li>Easy to collaborate with designer or markup enginner</li>
    </td>
    <td>
      <ul>
        <li>Cannot define plural Procedures in one file</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td>Karax</td>
    <td>
      <li>Available to define plural Procedures in one file</li>
      <li>Available to use `if` statement and `for` statement</li>
    </td>
    <td>
      <ul>
        <li>Maybe difficult to collaborate with designer or markup enginner</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td>nim-templates</td>
    <td>
      <ul>
        <li>Available to define plural Procedures in one file</li>
        <li>Available to use `if` statement and `for` statement</li>
        <li>Easy to collaborate with designer or markup enginner</li>
      </ul>
    </td>
    <td>
      <ul>
        <li>Maintained by a person</li>
      </ul>
    </td>
  </tr>
</table>

Views file should be in `resources` dir.

## Csrf Token
To send POST request from `form`, you have to set `csrf token`. You can use helper function from `basolato/view`

### nim-templates
```nim
import basolato/view
import templates

proc index*():string = tmpli html"""
<form>
  $(csrfToken())
  <input type="text", name="name">
</form>
"""
```

### htmlgen
```nim
import htmlgen
import basolato/view

proc index*():string =
  form(
    csrfToken(),
    input(type="text", name="name")
  )
```

### SCF
```nim
#? stdtmpl | standard
#import basolato/view
#proc index*():string =
<form>
  ${csrfToken()}
  <input type="text", name="name">
</form>
```

### Karax
```nim
import basolato/view
import karax / [karaxdsl, vdom]

proc index*():string =
  var vnode = buildView(form):
    csrfTokenKarax()
    input(type="text", name="name")
  return $vnode
```

## Block components example

Controller and result is same for each example.

controller
```nim
proc index*(): Response =
  let message = "Basolato"
  return render(indexView(message))
```

result
```html
<html>
  <head>
    <title>Basolato</title>
  </head>
  <body>
    <p>Basolato</p>
  </body>
</html>
```

### nim-templates

```nim
import tamplates

proc baseImpl(content:string): string = tmpli html"""
<html>
  <heade>
    <title>Basolato</title>
  </head>
  <body>
    $(content)
  </body>
</html>
"""

proc indexImpl(message:string): string = tmpli html"""
<p>$message</p>
"""

proc indexView*(message:string): string =
  baseImpl(indexImpl(message))
```

### htmlgen

```nim
import htmlgen

proc baseImpl(content:string): string =
  html(
    head(
      title("Basolato")
    ),
    body(content)
  )

proc indexImpl(message:string): string =
  p(message)

proc indexView*(message:string): string =
  baseImpl(indexImpl(message))
```


### SCF

SCF should divide procs for each file

baseImpl.nim
```nim
#? stdtmpl | standard
#proc baseImpl*(content:string): string =
<html>
  <heade>
    <title>Basolato</title>
  </head>
  <body>
    $content
  </body>
</html>
```

indexImpl.nim
```nim
#? stdtmpl | standard
#proc indexImpl*(message:string): string =
<p>$message</p>
```

index_view.nim
```nim
#? stdtmpl | standard
#import baseImpl
#import indexImpl
#proc indexView*(message:string): string =
${baseImpl(indexImpl(message))}
```

### Karax
This usage is **Server Side HTML Rendering**

```nim
import karax / [karasdsl, vdom]

proc baseImpl(content:string): string =
  var vnode = buildView(html):
    head:
      title: text("Basolato")
    body: text(content)
  return $vnode

proc indexImpl(message:string): string =
  var vnode = buildView(p):
    text(message)
  return $vnode

proc indexView*(message:string): string =
  baseImpl(indexImpl(message))
```

## old helper
If the user's input value is invalid and you want to back the input page and display the previously entered value, you can use `old` helper function.

controller
```nim
# get access
proc signinPage*(this:LoginController):Response =
  return render(this.view.signinView())

# post access
proc signin(this:LoginController):Response =
  let params = this.request.params()
  let email = params["email"]
  try
    ...
  except:
    return render(Http422, this.view.signinView(%params))
```

view
```nim
proc impl(params=newJObject()):string = tmpli html"""
<input type="text" name="email" value="$(old(params, "email"))">
<input type="text" name="password">
"""

proc signinView*(this:View, params=newJObject()):string =
  let title = "SignIn"
  return this.applicationView(title, impl(params))
```
It display value if `params` has key `email`, otherwise display empty string.


## Auth

You can access `auth` in view like bellow.

controller
```nim
proc home*(this:StaticPageController):Response =
  return render(this.view.homeView())
```

view
```html
import basolato/view

proc headerView*(auth:Auth):string = tmpli html"""
<header>
  <ul>
    $if auth.isLogin(){
      <li>$(auth.get("id"))</li>
    }
    $else{
      <li><a href="/login">Log In</a></li>
    }
  </ul>
</header>


proc applicationView*(this:View, title:string, body:string, flash=newJObject()):string = tmpli html"""
<!DOCTYPE html>
<html>
  <head>
  </head>
  <body>
    $(headerView(this.auth))
    ...
  </body>
</html>

proc homeView*(this:View):string =
  this.applicationView("Title", impl())
"""

```
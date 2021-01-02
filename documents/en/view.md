View
===
[back](../../README.md)

Table of Contents

<!--ts-->
   * [View](#view)
      * [Introduction](#introduction)
         * [Block component example](#block-component-example)
            * [nim-templates](#nim-templates)
            * [htmlgen](#htmlgen)
            * [SCF](#scf)
            * [Karax](#karax)
      * [Component design](#component-design)
         * [API](#api)
      * [Helper functions](#helper-functions)
         * [Csrf Token](#csrf-token)
         * [old helper](#old-helper)

<!-- Added by: root, at: Sun Dec 27 18:19:37 UTC 2020 -->

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

### Block component example

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

#### nim-templates

```nim
import basolato/view

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

#### htmlgen

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

#### SCF
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

#### Karax
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

## Component design
Basolato view is designed for component oriented design like React and Vue.  
Component is a single chunk of html and css, and just a procedure that return html string.

controller
```nim
import basolato/controller

proc withStylePage*(request:Request, params:Params):Future[Response] {.async.} =
  return render(withStyleView())
```

view
```nim
import basolato/view

let style = block:
  var css = newCss()
  css.set("background", "", """
    height: 200px;
    width: 200px;
    background-color: blue;
  """)
  css.set("background", ":hover", """
    background-color: green;
  """)
  css

proc component():string = tmpli html"""
$(style.define())
<div class="$(style.get("background"))"></div>
"""

proc impl():string = tmpli html"""
$(component())
"""

proc withStyleView*():string =
  let title = "Title"
  return applicationView(title, impl())
```

This is compiled to this html
```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Title</title>
  </head>
  <body>
    <style type="text/css">
      .background_jtshlgnucxj {
        height: 200px;
        width: 200px;
        background-color: blue;
      }
      .background_jtshlgnucxj:hover {
        background-color: green;
      }
    </style>
    <div class="background_jtshlgnucxj"></div>
  </body>
</html>
```

`Css` is a useful type for creating per-component style inspired by `CSS-in-JS`.
Styled class names have a random suffix per component, so multiple components can have the same class name.
At first time if you create view for component.

### API
```nim
proc newCss*():Css =

proc set*(this:var Css, className, option:string, value:string) =

proc get*(this:Css, className:string):string =

proc define*(this:Css):string =
```


## Helper functions

### Csrf Token
To send POST request from `form`, you have to set `csrf token`. You can use helper function from `basolato/view`

```nim
import basolato/view

proc index*():string = tmpli html"""
<form>
  $(csrfToken())
  <input type="text", name="name">
</form>
"""
```

### old helper
If the user's input value is invalid and you want to back the input page and display the previously entered value, you can use `old` helper function.

API
```nim
proc old*(params:JsonNode, key:string):string =

proc old*(params:TableRef, key:string):string =

```

controller
```nim
# get access
proc signinPage*(request:Request, params:Params):Future[Response] {.async.} =
  return render(signinView())

# post access
proc signin*(request:Request, params:Params):Future[Response] {.async.} =
  let email = params.getStr("email")
  try
    ...
  except:
    return render(Http422, signinView(%params))
```

view
```nim
proc impl(params=newJObject()):string = tmpli html"""
<input type="text" name="email" value="$(old(params, "email"))">
<input type="text" name="password">
"""

proc signinView*(params=newJObject()):string =
  let title = "SignIn"
  return this.applicationView(title, impl(params))
```
It display value if `params` has key `email`, otherwise display empty string.

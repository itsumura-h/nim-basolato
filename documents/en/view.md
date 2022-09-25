View
===
[back](../../README.md)

Table of Contents

<!--ts-->
* [View](#view)
   * [Introduction](#introduction)
   * [Template syntax](#template-syntax)
      * [if](#if)
      * [for](#for)
      * [while](#while)
   * [Component style design](#component-style-design)
      * [CSS](#css)
      * [SCSS](#scss)
      * [API](#api)
   * [Helper functions](#helper-functions)
      * [Csrf Token](#csrf-token)
      * [old helper](#old-helper)
   * [Uses SCF as template engine](#uses-scf-as-template-engine)

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->
<!-- Added by: root, at: Fri Sep 23 13:13:51 UTC 2022 -->

<!--te-->

## Introduction
Basolato uses the customized version of [nim-templates](https://github.com/onionhammer/nim-templates) as a default template engin. It can be used by importing `basolato/view`.

```nim
import basolato/view

proc baseImpl(content:Component): Component =
  tmpli html"""
    <html>
      <heade>
        <title>Basolato</title>
      </head>
      <body>
        $(content)
      </body>
    </html>
  """

proc indexImpl(message:string): Component =
  tmpli html"""
    <p>$(message)</p>
  """

proc indexView*(message:string): string =
  $baseImpl(indexImpl(message))
```

## Template syntax
### if
```nim
proc indexView(arg:string):Component =
  tmpli html"""
    $if arg == "a"{
      <p>A</p>
    }
    $elif arg == "b"{
      <p>B</p>
    }
    $else{
      <p>C</p>
    }
  """
```

### for
```nim
proc indexView(args:openarray[string]):Component =
  tmpli html"""
    <li>
      $for row in args{
        <ul>$(row)</ul>
      }
    </li>
  """
```

### while
```nim
proc indexView(args:openarray[string]):Component =
  tmpli html"""
    <ul>
      ${ var y = 0 }
      $while y < 4 {
        <li>$(y)</li>
        ${ inc(y) }
      }
    </ul>
  """
```

## Component style design
Basolato view is designed for component oriented design like React and Vue.  
Component is a single chunk of html, JavaScriptand and css, and just a procedure that return html string.  
Basolato provides a type `Componnet` to realize the parent-child structure of components. Use `Component` for the return value of a component.

### CSS
controller
```nim
import basolato/controller

proc withStylePage*(request:Request, params:Params):Future[Response] {.async.} =
  return render(withStyleView())
```

view
```nim
import basolato/view


proc impl():Component = 
  let style = styleTmpl(Css, """
    <style>
      .background {
        height: 200px;
        width: 200px;
        background-color: blue;
      }

      .background:hover {
        background-color: green;
      }
    </style>
  """

  tmpli html"""
    $(style)
    <div class="$(style.element("background"))"></div>
  """

proc withStyleView*():string =
  let title = "Title"
  return $applicationView(title, impl())
```

This is compiled to html like this.
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
      .background_jtshlgnucx {
        height: 200px;
        width: 200px;
        background-color: blue;
      }
      .background_jtshlgnucx:hover {
        background-color: green;
      }
    </style>
    <div class="background_jtshlgnucx"></div>
  </body>
</html>
```

`style` template is a useful type for creating per-component style inspired by `CSS-in-JS`.
Styled class names have a random suffix per component, so multiple components can have the same class name.

### SCSS
You can also use SCSS by installing [libsass](https://github.com/sass/libsass/).

```sh
apt install libsass-dev
# or
apk add --no-cache libsass-dev
```

Then you can write style block like this.
```nim
let style = styleTmpl(Scss, """
  <style>
    .background {
      height: 200px;
      width: 200px;
      background-color: blue;

      &:hover {
        background-color: green;
      }
    }
  </style>
"""
```

### API
`styleTmpl` proc create `Style` type instance.

```nim
type StyleType* = enum
  Css, Scss

proc styleTmpl*(typ:StyleType, body:string):Style

proc element*(self:Style, name:string):string
```

## Helper functions

### Csrf Token
To send POST request from `form`, you have to set `csrf token`. You can use helper function from `basolato/view`

```nim
import basolato/view

proc index*():Component =
  tmpli html"""
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
proc old*(params:JsonNode, key:string, default=""):string
proc old*(params:TableRef, key:string, default=""):string
proc old*(params:Params, key:string, default=""):string
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
proc impl(params=newJObject()):Component =
  tmpli html"""
    <input type="text" name="email" value="$(old(params, "email"))">
    <input type="text" name="password">
  """

proc signinView*(params=newJObject()):string =
  let title = "SignIn"
  return $applicationView(title, impl(params))
```
It display value if `params` has key `email`, otherwise display empty string.

## Uses SCF as template engine
You can also use [SCF](https://nim-lang.org/docs/filters.html) as a template engine with only a few modifications.

1. replace `#? stdtmpl | standard` to `#? stdtmpl(toString="toString") | standard`
1. import `basolato/view`
1. return type should be `Component`
1. replace `result = ""` to `result = Component.new()`
1. if you want to use in async, return type shoud be `Future[Component]` and add `{.async.}` pragma.

Full example
```nim
#? stdtmpl(toString="toString") | standard
#import std/asyncdispatch
#import basolato/view
#proc indexView*(str:string, arr:openArray[string]): Future[Component] {.async.} =
# result = Component.new()
<!DOCTYPE html>
<html lang="en">
  <body>
    <p>${str}</p>
    <ul>
      #for row in arr:
        <li>${row}</li>
      #end for
    </ul>
  </body>
</html>
```

controller
```nim
proc index(context:Context, params:Params):Future[Response] {.async.} =
  let str = "<script>alert('aaa')</script>"
  let arr = ["aaa", "bbb", "ccc"]
  return render(indexView(str, arr).await)
```

It you add `--scf` option for view creating command, SCF view will be created.
```sh
ducere make layout buttons/success_button --scf
ducere make page login --scf
```

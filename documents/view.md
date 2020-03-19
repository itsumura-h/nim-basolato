View
===
[back](../README.md)

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

# Csrf Token
To send POST request from `form`, you have to set `csrf token`. You can use helper function from `basolato/view`

## nim-templates
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

## htmlgen
```nim
import htmlgen
import basolato/view

proc index*():string =
  form(
    csrfToken(),
    input(type="text", name="name")
  )
```

## SCF
```nim
#? stdtmpl | standard
#import basolato/view
#proc index*():string =
<form>
  ${csrfToken()}
  <input type="text", name="name">
</form>
```

## Karax
```nim
import basolato/view
import karax / [karaxdsl, vdom]

proc index*():string =
  var vnode = buildHtml(form):
    csrfTokenKarax()
    input(type="text", name="name")
  return $vnode
```

# Block components example

Controller and result is same for each example.

controller
```nim
proc index*(): Response =
  let message = "Basolato"
  return render(indexHtml(message))
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

## nim-templates

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

proc indexHtml*(message:string): string =
  baseImpl(indexImpl(message))
```

## htmlgen

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

proc indexHtml*(message:string): string =
  baseImpl(indexImpl(message))
```


## SCF

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

indexHtml.nim
```nim
#? stdtmpl | standard
#import baseImpl
#import indexImpl
#proc indexHtml*(message:string): string =
${baseImpl(indexImpl(message))}
```

## Karax
This usage is **Server Side HTML Rendering**

```nim
import karax / [karasdsl, vdom]

proc baseImpl(content:string): string =
  var vnode = buildHtml(html):
    head:
      title: text("Basolato")
    body: text(content)
  return $vnode

proc indexImpl(message:string): string =
  var vnode = buildHtml(p):
    text(message)
  return $vnode

proc indexHtml*(message:string): string =
  baseImpl(indexImpl(message))
```

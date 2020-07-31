Controller
===
[back](../README.md)

Table of Contents

<!--ts-->
   * [Controller](#controller)
      * [Creating a Controller](#creating-a-controller)
      * [Constructor &amp; DI](#constructor--di)
      * [Response](#response)
         * [Returning string](#returning-string)
         * [Returning HTML file](#returning-html-file)
         * [Returning template](#returning-template)
         * [Returning JSON](#returning-json)
         * [Response status](#response-status)

<!-- Added by: root, at: Fri Jul 31 13:19:31 UTC 2020 -->

<!--te-->

## Creating a Controller
Use `ducere` command  
[ducere make controller](./ducere.md#controller)

Resource controllers are controllers that have basic CRUD / resource style methods to them.  
Generated controller is resource controller.

```nim
from strutils import parseInt
# framework
import basolato/controller


type SampleController* = ref object of Controller

proc newSampleController(request:Request):SampleController =
  return SampleController.newController(request)


proc index*(this:SampleController):Response =
  return render("index")

proc show*(this:SampleController, idArg:string):Response =
  let id = idArg.parseInt
  return render("show")

proc create*(this:SampleController):Response =
  return render("create")

proc store*(this:SampleController):Response =
  return render("store")

proc edit*(this:SampleController, idArg:string):Response =
  let id = idArg.parseInt
  return render("edit")

proc update*(this:SampleController):Response =
  return render("update")

proc destroy*(this:SampleController, idArg:string):Response =
  let id = idArg.parseInt
  return render("destroy")

```
## Constructor & DI
main.nim
```nim
routes
  get "/": newSampleController(request).index()

```

app/controllers/sample_controller.nim
```nim
type SampleController = ref object of Controller

proc newSampleController*(request:Request): SampleController =
  return SampleController.newController(request)

proc index*(this:SampleController): Response =
  this.request # Request
  this.auth # Auth
```

When you define controller object extends `Controller`, `request` and `auth` is initialized.

## Response
### Returning string
If you set string in `render` proc, controller returns string.
```nim
return render("index")
```

### Returning HTML file
If you set html file path in `html` proc, controller returns HTML.  
This file path should be relative path from `resources` dir

```nim
return render(html("sample/index.html"))

>> display /resources/sample/index.html
```

### Returning template
Call template proc with args in `render` will return template

resources/sample/index.nim
```nim
import basolato/view

proc indexHtml(name:string):string = tmpli html"""
<h1>index</h1>
<p>$name</p>
"""
```
main.nim
```nim
return render(indexHtml("John"))
```

### Returning JSON
If you set JsonNode in `render` proc, controller returns JSON.

```nim
return render(
  %*{"key": "value"}
)
```

### Response status
Put response status code arge1 and response body arge2
```nim
return render(HTTP500, "It is a response body")
```

[Here](https://nim-lang.org/docs/httpcore.html#10) is the list of response status code available.  
[Here](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes) is a experiment of HTTP status code

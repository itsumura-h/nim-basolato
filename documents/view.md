View
===
[back](../README.md)

## Introduction
Basolato use [nim-templates](https://github.com/onionhammer/nim-templates) as view. It is a usefull HTML templating library for Nim. You can use nim-templates by importing `basolate/view`.  
Views file should place in `resources` dir.

# Examples
## Display variable

view
```nim
import basolate/view

proc indexHtml*(message:string): string tmpli html"""
<p>$message</p>
"""
```

controller
```nim
proc index*(): Response =
  let message = "paragraph"
  return render(indexHtml(message))
```

result
```html
<p>paragraph</p>
```

## if
view
```nim
import basolate/view

proc indexHtml*(auth:string): string tmpli html"""
$if auth == "admin" {
  <p>You are administrator</p>
}
$elif auth == "user" {
  <p>You are user</p>
}
$else {
  <p>You don't have permission</p>
}
"""
```

controller
```nim
proc index*(): Response =
  let auth = "hoge"
  return render(indexHtml(auth))
```

result
```html
<p>You don't have permission</p>
```


## for
view
```nim
import basolate/view

proc indexHtml*(arr:oppenarray[int]): string tmpli html"""
<ul>
  $for row in arr {
    <il>$(row)</li>
  }
</ul>
"""
```

controller
```nim
proc index*(): Response =
  let arr = [1, 2, 3, 4, 5]
  return render(indexHtml(arr))
```

result
```html
<ul>
  <li>1</li>
  <li>2</li>
  <li>3</li>
  <li>4</li>
  <li>5</li>
</ul>
```

## Block components
view
```nim
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

proc indexHtml(message:string): string =
  baseImpl(indexImpl(message))
```

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

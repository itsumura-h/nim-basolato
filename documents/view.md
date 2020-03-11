View
===
[back](../README.md)

## Introduction
Basolato use [nim-templates](https://github.com/onionhammer/nim-templates) as view. It is a usefull HTML templating library for Nim. You can use nim-templates by importing `basolate/view`.  
Views file should place in `resources` dir.

# Examples
## SCF

See also [Official document](https://nim-lang.org/docs/filters.html)

### Display variable

view
```nim
#? stdtmpl | standard
#proc indexHtml*(message:string): string =
#  result = ""
<p>${message}</p>
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

### if statement
view
```nim
#? stdtmpl | standard
#proc indexHtml*(auth:string): string =
#  result = ""
#if auth == "admin":
  <p>You are administrator</p>
#elif auth == "user":
  <p>You are user</p>
#else:
  <p>You don't have permission</p>
#end if
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


### for statement
view
```nim
#? stdtmpl | standard
#proc indexHtml*(arr:oppenarray[int]): string =
#  result = ""
<ul>
  #for row in arr:
    <il>${row}</li>
  # end for
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

### Block components
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

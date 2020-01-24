Error
===
[back](../README.md)

## Introduction
When exception raised, Basolato will catch excepton and return Exception status response.  

```nim
raise newException(Error403, "session timeout")
```
It return `403 response` and 'session timeout' will be in response body.

Basolato have all response status exception type from `100` to `505`  
[List of HTTP Status](https://nim-lang.org/docs/httpcore.html#10)

## How to display custom error page
These raised exception is caught in framework routing

main.nim
```nim
routes:
  # Framework
  error Http404:
    http404Route
  error Exception:
    exceptionRoute
```

Basolate have it's own error page. If you set arg which is path to HTML file in `http404Route` and `exceptionRoute`, you can display custom error page.

main.nim
```nim
routes:
  # Framework
  error Http404:
    http404Route("errors/original404.html")
  error Exception:
    exceptionRoute("errors/originalError.html")
```
This path should be related path from `resources` dir.

```sh
└── resources
    └── errors
        ├── original404.html # user custom error
        └── originalError.html # user custom error
```
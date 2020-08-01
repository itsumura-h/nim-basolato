Error
===
[back](../README.md)

Table of Contents

<!--ts-->
   * [Error](#error)
      * [Introduction](#introduction)
      * [ErrorAuthRedirect](#errorauthredirect)
      * [Raise Error and Redirect](#raise-error-and-redirect)
      * [How to display custom error page](#how-to-display-custom-error-page)

<!-- Added by: root, at: Sat Aug  1 12:13:38 UTC 2020 -->

<!--te-->

## Introduction
When exception raised, Basolato will catch excepton and return Exception status response.  

```nim
raise newException(Error403, "session timeout")
```
It return `403 response` and 'session timeout' will be in response body.

Basolato have all response status exception type from `300` to `505`  
[List of HTTP Status](https://nim-lang.org/docs/httpcore.html#10)


## ErrorAuthRedirect
If session id is invalid then you want to redirect and delete cookie, raise `ErrorAuthRedirect` exception.
```nim
if not newAuth(request).isLogin():
  raise newException(ErrorAuthRedirect, "/login")
```

## Raise Error and Redirect
If you want to redirect when error raised, you can use `errorRedirect` proc.  
This proc is able to used only in `controller` or `middleware`.

```nim
errorRedirect("/login")
```

## How to display custom error page
These raised exception is caught in framework routing

main.nim
```nim
routes:
  # Framework
  error Http404: http404Route
  error Exception: exceptionRoute
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

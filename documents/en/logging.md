Logging
===
[Back](../../README.md)

Table of Contents

<!--ts-->
   * [Logging](#logging)
      * [Introduction](#introduction)
      * [API](#api)
      * [Sample](#sample)

<!-- Added by: root, at: Wed Sep  8 16:11:35 UTC 2021 -->

<!--te-->

## Introduction
If the environment variable `LOG_IS_DISPLAY` is set to `true`, arges of `echoLog` and `echoErrorMsg` will be displayed in the terminal. If `false` is set, it will not be displayed.

The environment variable `LOG_DIR` is the path of the directory to output log files.

If the environment variable `LOG_IS_FILE` is set to `true`, arges of `echoLog` will be output to the log file. If `false` is set, it will not be output.

If the environment variable `LOG_IS_ERROR_FILE` is set to `true`, arges of `echoErrorMsg` will be output to the error log file. If `false` is set, it will not be output.

## API
```nim
proc echoLog*(output: any, args:varargs[string]) =

proc echoErrorMsg*(msg:string) =
```

## Sample

```nim
import basolato/logging

proc index*(request:Request, params:Params):Future[Response] {.async.} =
  try:
    echoLog("index")
  except:
    echoErrorMsg( getCurrentExceptionMsg() )
```

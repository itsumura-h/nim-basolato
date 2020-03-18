import strutils, os, strtabs, strformat
import asynctools, asyncdispatch, asyncstreams

when isMainModule:
  var data = waitFor(execProcess("pwd"))
    
  echo "exitCode = " & $data.exitcode
  echo "output = [" & $data.output & "]"
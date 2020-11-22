import os

proc migrate*() =
  discard execShellCmd("nim c -r migrations/migrate")

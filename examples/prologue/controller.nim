import prologue

proc index*(ctx:Context){.async.} =
  echo ctx.session.repr
  resp "Hello"

proc show*(ctx:Context){.async.} =
  resp "show"
import
  functions/newImpl,
  functions/makeImpl,
  functions/serveImpl

when isMainModule:
  import cligen
  dispatchMulti(
    [newImpl.new],[make],[serve]
  )

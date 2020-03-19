import
  functions/newImpl,
  functions/makeImpl,
  functions/serveImpl,
  functions/buildImpl

when isMainModule:
  import cligen
  dispatchMulti(
    [newImpl.new],[make],[serve],[build]
  )

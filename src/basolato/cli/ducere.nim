import
  ../core/base,
  functions/newImpl,
  functions/makeImpl,
  functions/serveImpl,
  functions/buildImpl

when isMainModule:
  import cligen
  clCfg.version = basolatoVersion
  dispatchMulti(
    [newImpl.new],[make],[serve],[build]
  )
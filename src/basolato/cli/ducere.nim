import
  ../core/base,
  functions/newImpl,
  functions/makeImpl,
  functions/serveImpl,
  functions/buildImpl,
  functions/migrateImpl

when isMainModule:
  import cligen
  clCfg.version = BasolatoVersion
  dispatchMulti(
    [newImpl.new],[make],[serve],[build],[migrate]
  )

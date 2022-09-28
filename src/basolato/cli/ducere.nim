import
  ../std/core/base,
  functions/newImpl,
  functions/makeImpl,
  functions/serveImpl,
  functions/buildImpl,
  functions/migrateImpl,
  functions/seedImpl

when isMainModule:
  import cligen
  clCfg.version = BasolatoVersion
  dispatchMulti(
    [newImpl.new],[make],[serve],[build],[migrate],[seed]
  )

import ../core/base
import ./functions/newImpl
import ./functions/makeImpl
import ./functions/serveImpl
import ./functions/buildImpl
import ./functions/migrateImpl
import ./functions/seedImpl

when isMainModule:
  import cligen
  clCfg.version = BasolatoVersion
  dispatchMulti(
    [newImpl.new],[make],[serve],[build],[migrate],[seed]
  )

import
  functions/createProject,
  functions/makeFile,
  functions/runServer

when isMainModule:
  import cligen
  dispatchMulti(
    [createProject.new],
    [makeFile.make],
    [runServer.serve]
  )

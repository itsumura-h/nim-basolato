import
  shiotsuchi/createProject,
  shiotsuchi/makeFile

when isMainModule:
  import cligen
  dispatchMulti(
    [createProject.new],
    [makeFile.make]
  )

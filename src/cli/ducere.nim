import
  functions/createProject,
  functions/makeFile

when isMainModule:
  import cligen
  dispatchMulti(
    [createProject.new],
    [makeFile.make]
  )

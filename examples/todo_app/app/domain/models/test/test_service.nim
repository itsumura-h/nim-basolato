import test_entity
import test_repository_interface

type TestService* = ref object
  repository:ITestRepository

proc newTestService*():TestService =
  return TestService(
    repository:newITestRepository()
  )

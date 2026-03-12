import ../../../../../../../src/basolato/view


type FileUploadPageViewModel* = object
  csrfToken*: string


proc new*(_: type FileUploadPageViewModel, csrfToken: string = ""): FileUploadPageViewModel =
  return FileUploadPageViewModel(
    csrfToken: csrfToken
  )

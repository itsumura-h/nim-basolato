import ../../../../../../../src/basolato/view
import ../../presenters/file_upload/file_upload_page_viewmodel


proc fileUploadTemplate*(vm: FileUploadPageViewModel): Component


proc fileUploadPage*():Component =
  let vm = FileUploadPageViewModel.new()
  return fileUploadTemplate(vm)


proc fileUploadTemplate*(vm: FileUploadPageViewModel): Component =
  tmpl"""
    <main>
      <a href="/">go back</a>
      <form method="POST" enctype="multipart/form-data">
        $(csrfToken())
        <p>
          <span>image file named [test.jpg]</span>
          <input type="file" name="img">
        </p>
        <button type="submit">upload</button>
      </form>
      <form method="POST" action="/sample/file-upload/delete">
        $(csrfToken())
        <button type="submit">delete</button>
      </form>
      <div>
        <img src="/sample/test.jpg">
        <img src="/sample/image.jpg">
      </div>
    </main>
  """

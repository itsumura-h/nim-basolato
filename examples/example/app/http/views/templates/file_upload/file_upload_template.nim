import ../../../../../../../src/basolato/view
import ../../presenters/file_upload/file_upload_page_viewmodel


proc fileUploadTemplate*(vm: FileUploadPageViewModel): Component =
  let csrfTokenStr = vm.csrfToken
  tmpl"""
    <main>
      <a href="/">go back</a>
      <form method="POST" enctype="multipart/form-data">
        <input type="hidden" name="csrf_token" value="$(escapeHtmlAttr(csrfTokenStr))">
        <p>
          <span>image file named [test.jpg]</span>
          <input type="file" name="img">
        </p>
        <button type="submit">upload</button>
      </form>
      <form method="POST" action="/sample/file-upload/delete">
        <input type="hidden" name="csrf_token" value="$(escapeHtmlAttr(csrfTokenStr))">
        <button type="submit">delete</button>
      </form>
      <div>
        <img src="/sample/test.jpg">
        <img src="/sample/image.jpg">
      </div>
    </main>
  """

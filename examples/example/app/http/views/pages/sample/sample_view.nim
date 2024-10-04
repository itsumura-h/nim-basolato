import ../../../../../../../src/basolato/view

proc sampleView*():Component =
  tmpl"""
    <main>
      <article>
        <h2>Examples</h2>
        <p><a href="/sample/welcome" data-turbo="false">welcome</a></p>
        <p><a href="/sample/fib/30">fib</a></p>
        <p><a href="/sample/with-style">with style</a></p>
        <p><a href="/sample/babylon-js" data-turbo="false">Babylon.js</a></p>
        <p><a href="/sample/api">API sample</a></p>
        <p><a href="/sample/custom-headers">with Custom Headers</a></p>
        <p><a href="/sample/dd" data-turbo="false">dd</a></p>
        <p><a href="/sample/error/1">error page</a></p>
        <p><a href="/sample/error-redirect/1">error redirect</a></p>
        <p><a href="/sample/error-redirect/2">error not redirect</a></p>
        <p><a href="/sample/cookie">cookie</a></p>
        <p><a href="/sample/login">login</a></p>
        <p><a href="/sample/flash">flash message</a></p>
        <p><a href="/sample/file-upload">file upload</a></p>
        <p><a href="/sample/validation">validation</a></p>
        <p><a href="/sample/web-socket">web socket</a></p>
      </article>
    </main>
  """

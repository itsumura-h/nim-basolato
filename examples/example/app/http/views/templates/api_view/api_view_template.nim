import ../../../../../../../src/basolato/view


proc apiViewTemplate*():Component =
  let style = styleTmpl(Css, """
    <style>
      pre {
        margin: 0px;
      }
    </style>
  """)

  tmpl"""
    <link rel="stylesheet" href="//cdnjs.cloudflare.com/ajax/libs/highlight.js/11.6.0/styles/vs2015.min.css">
    <script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/11.6.0/highlight.min.js"></script>
    $(style)
    <script>
      // fetchベースでAPI呼び出しを行うテンプレートです
      const baseURL = 'http://localhost:8000/api'
      const baseHeaders = {
        'Access-Control-Allow-Origin': 'http://localhost:8000'
      }

      const setResult = (resp) => {
        const el = document.getElementById('result')
        el.innerHTML = JSON.stringify(resp, null, '  ')
        hljs.highlightElement(el)
      }

      const apiRequest = async (method, path, body) => {
        const headers = {
          ...baseHeaders
        }
        const options = {
          method,
          headers,
          credentials: 'include'
        }
        if (body !== undefined) {
          headers['Content-Type'] = 'application/json'
          options.body = JSON.stringify(body)
        }

        const response = await fetch(baseURL + path, options)
        const contentType = response.headers.get('Content-Type') || ''
        let payload
        if (contentType.includes('application/json')) {
          payload = await response.json()
        } else {
          payload = await response.text()
        }

        return {
          status: response.status,
          ok: response.ok,
          headers: {
            'content-type': contentType
          },
          body: payload
        }
      }

      const readParam = () => {
        const raw = document.getElementById('param').value
        return JSON.parse(raw)
      }

      const getRequest = async () => {
        const resp = await apiRequest('GET', '/sample')
        setResult(resp)
      }

      const postRequest = async () => {
        const resp = await apiRequest('POST', '/sample', readParam())
        setResult(resp)
      }

      const patchRequest = async () => {
        const resp = await apiRequest('PATCH', '/sample', readParam())
        setResult(resp)
      }

      const putRequest = async () => {
        const resp = await apiRequest('PUT', '/sample', readParam())
        setResult(resp)
      }

      const deleteRequest = async () => {
        const resp = await apiRequest('DELETE', '/sample', readParam())
        setResult(resp)
      }
    </script>
    <main>
      <article>
        <div class="$(style.element(" className"))">
          <a href="/">go back</a>
          <h2>JSON request body</h2>
          <textarea id="param" rows="5">
{
  "key": "value"
}
          </textarea>
          <button type="button" onclick="getRequest()">get</button>
          <button type="button" onclick="postRequest()">post</button>
          <button type="button" onclick="patchRequest()">patch</button>
          <button type="button" onclick="putRequest()">put</button>
          <button type="button" onclick="deleteRequest()">delete</button>
          <pre>
            <code class="language-json hljs" id="result"></code>
          </pre>
        </div>
      </article>
    </main>
  """

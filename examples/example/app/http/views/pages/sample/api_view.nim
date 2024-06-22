import
  std/asyncdispatch,
  std/json,
  ../../../../../../../src/basolato/view,
  ../../layouts/application_view


proc impl():Future[Component] {.async.} =
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
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
    <script>
      const request = axios.create({
        withCredentials: true,
        baseURL: 'http://localhost:8000/api',
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': 'http://localhost:8000'
        }
      })

      const setResult=(resp)=>{
        const el = document.getElementById('result');
        el.innerHTML = JSON.stringify(resp, null, "  ");
        hljs.highlightElement(el);
      }

      const getRequest=async()=>{
        const resp = await request.get('/sample')
        setResult(resp)
      }

      const postRequest=async()=>{
        let param = document.getElementById('param').value
        param = JSON.parse(param)
        const resp = await request.post('/sample', param)
        setResult(resp)
      }

      const patchRequest=async()=>{
        let param = document.getElementById('param').value
        param = JSON.parse(param)
        const resp = await request.patch('/sample', param)
        setResult(resp)
      }

      const putRequest=async()=>{
        let param = document.getElementById('param').value
        param = JSON.parse(param)
        const resp = await request.put('/sample', param)
        setResult(resp)
      }

      const deleteRequest=async()=>{
        let param = document.getElementById('param').value
        param = JSON.parse(param)
        const resp = await request.delete('/sample', param)
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

proc apiView*():Future[Component] {.async.} =
  let title = ""
  return applicationView(title, impl().await)

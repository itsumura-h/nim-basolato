import
  std/asyncdispatch,
  std/json,
  ../../../../../../../src/basolato/view,
  ../../layouts/application_view


proc impl():Future[Component] {.async.} =
  style "css", style:"""
    <style>
      .className {}
    </style>
  """

  tmpli html"""
  $(style)
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
    <script>
      const request = axios.create({
        withCredentials: true,
        baseURL: 'http://localhost:9000/api',
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': 'http://localhost:9000'
        }
      })

      const setResult=(resp)=>{
        document.getElementById('result').innerText = JSON.stringify(resp, null, 2)
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
    <div class="$(style.element(" className"))">
      <a href="/">go back</a>
      <h2>JSON request body</h2>
      <textarea id="param">
{
  "key": "value"
}
      </textarea>
      <button type="button" onclick="getRequest()">get</button>
      <button type="button" onclick="postRequest()">post</button>
      <button type="button" onclick="patchRequest()">patch</button>
      <button type="button" onclick="putRequest()">put</button>
      <button type="button" onclick="deleteRequest()">delete</button>
      <pre id="result"></pre>
    </div>
  """

proc apiView*():Future[string] {.async.} =
  let title = ""
  return $applicationView(title, impl().await)
import ../../../src/basolato/view

proc editHtml*(id:int, title:string, post:string, user:string, error:string):string = tmpli html"""
<p><a href="/MVCPosts/$(id)">Back</a></p>
<h1>edit</h1>
$if error.len > 0 {
  <p style="background-color: yellow; color: red">$(error)</p> 
}
<form method="post">
  <p>id: $(id)</p>
  <p>title:<input type="text" name="title" value="$(title)"></p>
  <p>By $(user)</p>
  <div>
    <p>content:</p>
    <textarea name="post">$(post)</textarea>
  </div>
    <button type="submit">update</button>
</form>
"""

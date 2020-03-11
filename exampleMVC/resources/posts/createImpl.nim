#? stdtmpl | standard
#import json
## framework
#import ../../../src/basolato/view
##import ../base
#proc createHtmlImpl*(title:string, text:string, errors:JsonNode): string =
<h2>New Post</h2>
<form method="post">
  ${csrfToken()}
  <div>
    <p>Title</p>
    #if errors.hasKey("title"):
      <ul>
        #for row in errors["title"]:
          <li>${row.get}</li>
        #end for
      </ul>
    #end if
    <p><input type="text" value="${title}" name="title"></p>
  </div>
  <div>
    <p>Text</p> 
    #if errors.hasKey("text"):
      <ul>
        #for row in errors["text"]:
          <li>${row.get}</li>
        #end for
      </ul>
    #end if
    <textarea name="text">$text</textarea>
  </div>
  <button type="submit">create</button>
</form>

import md5, json, strformat, htmlgen

proc gravatar_for*(user:JsonNode, size=80):string =
  let gravatar_id = user["email"].getStr().getMD5()
  let gravatar_url = &"https://secure.gravatar.com/avatar/{gravatar_id}?s={size}"
  return img(src=gravatar_url, alt=user["name"].getStr(), class="gravatar")

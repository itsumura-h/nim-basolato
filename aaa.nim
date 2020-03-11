import htmlgen

proc genHtml():string =
  ul(
    for i in 0..3:
      return li($i),
  )
    
  # ul(
  #   li($1),
  #   li($2),
  #   li($3)
  # )
    

echo genHtml()
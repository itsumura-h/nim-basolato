import karax/karax

type Page1* = ref object
  name*:string
  text1*:string
  text2*:string
  list*:seq[tuple[key, value:string]]

type Page2* = ref object
  name*:string
  text1*:string
  text2*:string
  list*:seq[tuple[key, value:string]]

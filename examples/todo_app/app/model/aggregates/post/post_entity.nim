import ../../value_objects


type Post* = ref object


proc newPost*():Post =
  return Post()

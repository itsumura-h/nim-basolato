from strutils import parseInt
from json import `$`
include ../services/domain_services/SampleService

# html
import  "../resources/templates/sample/index.tmpl"


proc index*(): string =
  return index_html()

proc fib*(num: string): JsonNode =
  let new_num = num.parseInt
  return SampleService().fib(new_num)

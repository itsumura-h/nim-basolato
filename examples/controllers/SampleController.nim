from strutils import parseInt
from json import `$`
import ../../src/shiotsuchi/controller
include ../services/domain_services/SampleService

# html
import  "../resources/templates/sample/index.tmpl"


proc index*(): Response =
  return render(index_html())

proc fib*(num: string): Response =
  let new_num = num.parseInt
  return render(SampleService().fib(new_num))

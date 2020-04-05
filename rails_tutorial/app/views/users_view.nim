import json
import ../../resources/users/create
import ../../resources/users/show

proc usersCreateView*():string =
  return createHtml()

proc usersShowView*(user:JsonNode):string =
  return showHtml(user)
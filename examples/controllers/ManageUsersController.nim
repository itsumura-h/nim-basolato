import jester
import json
from strutils import parseInt

# service
# include ../services/domain_services/ManageUsersService
import ../services/domain_services/ManageUsersService

# html
include ../resources/templates/base
include ../resources/templates/manage_users/index
include ../resources/templates/manage_users/show
include ../resources/templates/manage_users/create

proc index*(): string =
  let users = ManageUsersService().index()
  let str_users = $users
  let header = $[
    %*{"text": "id", "value": "id"},
    %*{"text": "name", "value": "name"},
    %*{"text": "email", "value": "email"},
    %*{"text": "birth_date", "value": "birth_date"},
    %*{"text": "created_at", "value": "created_at"},
    %*{"text": "updated_at", "value": "updated_at"},
    %*{"text": "action", "value": "action"}
  ]

  return base_html(index_html(header, str_users))


proc create*(): string =
  return create_html()


proc store*(request: Request): string =
  var params = request.params
  # echo params
  echo params["name"]
  echo params["email"]
  echo params["birth_date"]
  return ""


proc show*(str_id: string): string =
  let id = str_id.parseInt
  let user = ManageUsersService().show(id)
  return show_html(user)


proc update*(str_id: string): JsonNode =
  let id = str_id.parseInt
  var data = %*{"id": id}
  return data

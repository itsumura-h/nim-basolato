import json
from strutils import parseInt
import ../../../src/basolato/controller

# service
import ../services/domain_services/ManageUsersService

# html
import ../../resources/base
import ../../resources/manage_users/index
import ../../resources/manage_users/show
import ../../resources/manage_users/create

proc index*(): Response =
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

  return render(
    base_html(index_html(header, str_users))
  )


proc create*(): Response =
  return render(create_html())


proc store*(request: Request): Response =
  var params = request.params
  # echo params
  echo params["name"]
  echo params["email"]
  echo params["birth_date"]
  return render("")


proc show*(str_id: string): Response =
  let id = str_id.parseInt
  let user = ManageUsersService().show(id)
  return render(show_html(user))


proc update*(str_id: string): Response =
  let id = str_id.parseInt
  var data = %*{"id": id}
  return render(data)

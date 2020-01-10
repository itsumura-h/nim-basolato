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

type ManageUserController* = ref object of Controller
  service: ManageUsersService


proc newManageUserController*(): ManageUserController =
  return ManageUserController(
    service: newManageUsersService()
  )

proc index*(this:ManageUserController): Response =
  let users = %this.service.index()
  let header = %*[
    {"text": "id", "value": "id"},
    {"text": "name", "value": "name"},
    {"text": "email", "value": "email"},
    {"text": "birth_date", "value": "birth_date"},
    {"text": "created_at", "value": "created_at"},
    {"text": "updated_at", "value": "updated_at"},
    {"text": "action", "value": "action"}
  ]

  return render(
    base_html(index_html($header, $users))
  )

proc create*(this:ManageUserController): Response =
  return render(create_html())

proc store*(this:ManageUserController, request: Request): Response =
  var params = request.params
  # echo params
  echo params["name"]
  echo params["email"]
  echo params["birth_date"]
  return render("")

proc show*(this:ManageUserController, idArg:string): Response =
  let id = idArg.parseInt
  let user = this.service.show(id)
  return render(show_html(user))

proc update*(this:ManageUserController, idArg:string): Response =
  let id = idArg.parseInt
  var data = %*{"id": id}
  return render(data)

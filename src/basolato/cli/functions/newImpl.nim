import std/os
import std/strutils
import std/terminal
import ./make/config
from make/utils import isDirExists


type TemplateFile = tuple[path, content: string]


const templateDirs = [
  "app",
  "app/data_stores",
  "app/data_stores/dao",
  "app/data_stores/repositories",
  "app/http",
  "app/http/controllers",
  "app/http/middlewares",
  "app/http/views",
  "app/http/views/components",
  "app/http/views/errors",
  "app/http/views/layouts",
  "app/http/views/layouts/app",
  "app/http/views/layouts/footer",
  "app/http/views/layouts/head",
  "app/http/views/pages",
  "app/http/views/pages/welcome",
  "app/http/views/templates",
  "app/http/views/templates/welcome",
  "app/models",
  "app/models/aggregates",
  "app/models/dto",
  "app/models/vo",
  "app/usecases",
  "app/presenters",
  "config",
  "database",
  "database/migrations",
  "database/migrations/data",
  "database/seeders",
  "database/seeders/data",
  "public",
  "public/css",
  "public/js",
  "resources",
  "resources/lang",
  "resources/lang/en",
  "resources/lang/ja",
  "tests",
]


const
  template_gitignore = """
# Binaries
*
!*.*
!*/

# Test coverage
coverage/*
lcov.info

# IDE
.vscode/*

.env
*.out
*.log
*.log.*
*.sqlite3
*.db
*.db.*
startServer.sh
"""
  template_README_md = """
Di Container
===
Di Container provide repository implement of Interface. Passing the dependency of the Repository to the Service through the Di Container prevents the Service and Repository from becoming tightly coupled.

```nim
# user
import models/user/user_repository_interface
import data_stores/repositories/user/user_repository
# todo
import usecases/todo/todo_query_interface
import data_stores/query_services/todo/todo_query

type DiContainer* = tuple
  userRepository: IUserRepository
  todoQuery: ITodoQuery

proc newDiContainer():DiContainer =
  return (
    userRepository: UserRepository.new().toInterface(),
    todoQuery: TodoQuery.new().toInterface(),
  )

let di* = newDiContainer()
```

In this example, `Repository Interface` call `UserRdbRepository` by resolving as `userRepository`.
"""
  template_data_stores_dao_README_md = """
DAO - Data Access Object
===

The DAO is used to retrieve data from the outside. It returns a DTO.

The DAO exists in units of use cases and executes complex queries to the database across multiple aggregates.

Not only RDBs, but also external API access and NoSQL are implemented here.
"""
  template_data_stores_repositories_README_md = """
Repositories
===
Repository is a functions to instantiate and persisted `aggregate` model to access file or extrnal web API.  
`Repository` should be created in correspondence with the `aggregate`, a top of `Domain Model`.  
The task of `Repository` is CRUD for `aggregate`.

```nim
type UserRepository* = ref object

proc new*(_:type UserRepository):UserRdbRepository =
  return UserRdbRepository()

implements UserRepository, IUserRepository:
  proc getUserById*(self:UserRdbRepository, id:UserId):Future[User] {.async.} =
    let userOpt = await rdb.table("users").find(id.get)
    if not userOpt.isSome:
      raise newException(Exception, "user is not found")
    let user = userOpt.get
    return User.new(
      id,
      Name.new(user["name"].getStr),
      Email.new(user["email"].getStr),
      Password.new(user["password"].getStr),
    )

  proc insert*(self:UserRdbRepository, user:User):Future[int] {.async.} =
    return await rdb.table("users").insertId(%*{
      "id": user.id.get,
      "name": $user.name,
      "email": $user.email,
      "password": $user.password
    })

  proc save*(self:UserRdbRepository, user:User):Future[void] {.async.} =
    await rdb.table("users")
      .where("id", "=", user.id.get)
      .update(%*{
        "name": $user.name,
        "email": $user.email,
        "password": $user.password
      })

  proc delete*(self:UserRdbRepository, user:User):Future[void] {.async.}
    await rdb.table("users").delete(user.id.get)
```
"""
  template_di_container_nim = """
type DiContainer* = tuple

proc newDiContainer():DiContainer =
  return (
  )

let di* = newDiContainer()
"""
  template_http_controllers_README_md = """
Controllers
===
Controllers receive requests and choose the response to return.

## Naming

- `GET` handlers that render HTML should be named `XxxPage`.
- Those handlers should call `XxxPageView` in `http/views/pages`.
- Action-style handlers for `POST`, `PUT`, `DELETE`, and similar routes may keep verb-oriented names.

## Duties

- Receive request and URL parameters
- Perform validation checks
- Create model instances or call usecases
- Catch and handle exceptions
- Select the response object
- Return response data
"""
  template_http_controllers_welcome_controller_nim = """
import std/asyncdispatch
import std/json
# framework
import basolato/controller
import basolato/core/base
# view
import ../views/pages/welcome/welcome_page


proc welcomePage*(context:Context):Future[Response] {.async.} =
  let page = welcomePageView(context).await
  return render(page)

proc indexApi*(context:Context):Future[Response] {.async.} =
  return render(%*{"message": "Basolato " & BasolatoVersion})
"""
  template_http_middlewares_README_md = """
Middleware
===
This directory contains your application middleware.  
Middleware let you define custom functions that can be run for a certain URL path groups.

Middleware have to be this interface
```nim
proc (c:Context, p:Params):Future[Response]
```
"""
  template_http_middlewares_session_middleware_nim = """
import std/asyncdispatch
import basolato/middleware


proc checkCsrfToken*(c:Context):Future[Response] {.async.} =
  try:
    checkCsrfTokenForMpaHelper(c).await
    return next()
  except:
    # Define your own error handling logic here
    # return errorRedirect("/signin")
    return render(Http403, getCurrentExceptionMsg())


proc sessionFromCookie*(c:Context):Future[Response] {.async.} =
  try:
    let cookies = sessionFromCookieHelper(c).await
    return next().setCookie(cookies)
  except:
    # Define your own error handling logic here
    let cookies = createNewSessionHelper(c).await
    return next().setCookie(cookies)
    # return errorRedirect("/signin").setCookie(cookies)
"""
  template_http_middlewares_set_headers_middleware_nim = """
import std/asyncdispatch
import std/httpcore
import basolato/middleware


proc setCorsHeaders*(c:Context):Future[Response] {.async.} =
  if c.request.httpMethod != HttpOptions:
    return next()

  let allowedMethods = [
    "OPTIONS",
    "GET",
    "POST",
    "PUT",
    "DELETE"
  ]

  let allowedHeaders = [
    "Access-Control-Allow-Origin",
    "Content-Type",
    "*",
  ]

  let headers = {
    "Origin": @[$true],
    "Cache-Control": @["no-cache"],
    "Access-Control-Allow-Credentials": @[$true],
    "Access-Control-Allow-Origin": @["http://localhost:3000"],
    "Access-Control-Allow-Methods": @allowedMethods,
    "Access-Control-Allow-Headers": @allowedHeaders,
    "Access-Control-Expose-Headers": @allowedHeaders,
  }.newHttpHeaders()
  return next(status=Http204, headers=headers)


proc setSecureHeaders*(c:Context):Future[Response] {.async.} =
  if c.request.httpMethod != HttpOptions:
    return next()

  let headers = {
    "Strict-Transport-Security": @["max-age=63072000", "includeSubdomains"],
    "X-Frame-Options": @["SAMEORIGIN"],
    "X-XSS-Protection": @["1", "mode=block"],
    "X-Content-Type-Options": @["nosniff"],
    "Referrer-Policy": @["no-referrer", "strict-origin-when-cross-origin"],
    "Cache-Control": @["no-cache", "no-store", "must-revalidate"],
    "Pragma": @["no-cache"],
  }.newHttpHeaders()
  return next(status=Http204, headers=headers)
"""
  template_http_views_README_md = """Views
===

All HTML rendering code lives in this directory.

## Architecture

Basolato uses the **Controller → Page → PageView → Layout → Template → Component** flow.

```
HTTP Request
    ↓
Controller
    ↓
Page (`XxxPage`)
    ↓
PageView (`pages/*.nim`)
    ↓
Layout (`layouts/*.nim`)
    ↓
Template (`templates/*.nim`)
    ↓
Component (`components/*.nim`)
HTTP Response
```

## Naming

- `XxxPage` is the GET controller entrypoint name.
- `XxxPageView` is the UI entrypoint under `pages/`.
- `XxxLayoutModel`, `XxxTemplateModel`, and `XxxComponentModel` are the model names for each UI granularity.
- `ViewModel` is a conceptual term only; do not use it as a symbol name.

## Directory Structure

### pages/
HTTP entrypoints that compose layouts and templates.

**Responsibilities:**
- Receive `Context`
- Build page-level composition by assembling `LayoutModel` and `TemplateModel`
- Return a full HTML response

### layouts/
Shared frame, head, header, footer, and other page chrome.

**Responsibilities:**
- Define page frame
- Provide layout models for consistent structure
- Support nested layouts

### templates/
Render HTML for one UI boundary.

**Responsibilities:**
- Accept a `TemplateModel`
- Render HTML for one template boundary
- Avoid direct access to global request state

### components/
Reusable UI fragments within pages or templates.

**Responsibilities:**
- Encapsulate recurring UI patterns
- Accept minimal input, preferably a component model
- Avoid stateful behavior
"""
  template_http_views_components_README_md = """Components
===

This directory contains small reusable UI fragments.
Use components for markup that is shared across pages or templates and does not need to know about request-local state.
"""
  template_app_presenters_README_md = """
Presenters
==========

This directory contains optional helpers that transform request or business data before it reaches page or view code.

## Responsibilities

- Convert `Context`, DTOs, and small domain results into `Page`, `LayoutModel`, `TemplateModel`, or `ComponentModel` friendly values
- Keep transformation logic that would otherwise be duplicated in templates
- Return immutable model values named after the target UI granularity
- Stay request-local, side-effect free, and easy to test

## Usage

- Place page-specific presenters under `presenters/<page>/`
- Define `new*` or `invoke*` as the entry point
- Use presenters from pages or template-model construction code
- Keep presenters free from DB access and HTML rendering

## Naming

- Do not use `ViewModel` in symbol names.
- Prefer `Page`, `PageView`, `LayoutModel`, `TemplateModel`, and `ComponentModel`.
"""
  template_http_views_layouts_app_app_layout_model_nim = """import ../head/head_layout_model


type AppLayoutModel* = object
  headLayoutModel*:HeadLayoutModel

proc new*(_:type AppLayoutModel, headLayoutModel:HeadLayoutModel):AppLayoutModel =
  return AppLayoutModel(headLayoutModel:headLayoutModel)
"""
  template_http_views_layouts_app_app_layout_nim = """import basolato/view
import ../head/head_layout
import ./app_layout_model


proc appLayout*(appLayoutModel:AppLayoutModel, body:Component):Component =
  tmpl\"\"\"
    <!DOCTYPE html>
    <html lang="en">
      $(headLayout(appLayoutModel.headLayoutModel))
      <body>
        $(body)
      </body>
    </html>
  \"\"\"
"""
  template_http_views_layouts_footer_footer_layout_nim = """import basolato/view


proc footerLayout*():Component =
  let style = styleTmpl(Css, \"\"\"
    <style>
      .footer {
        background-color: gray;
      }
    </style>
  \"\"\"")
  
  tmpl\"\"\"
    $(style)
    <footer class="$(style.element("footer"))">
      <div>
        <p>
          &copy; 2026 Basolato. All rights reserved.
        </p>
      </div>
    </footer>
  \"\"\"
"""
  template_http_views_layouts_head_head_layout_model_nim = """type HeadLayoutModel* = object
  title*:string

proc new*(_:type HeadLayoutModel, title:string):HeadLayoutModel =
  return HeadLayoutModel(title:title)
"""
  template_http_views_layouts_head_head_layout_nim = """import basolato/view
import ./head_layout_model


proc headLayout*(model:HeadLayoutModel):Component =
  tmpl\"\"\"
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta charset="UTF-8">
      <title>$(model.title)</title>
      <script type="module">
        import hotwiredTurbo from "https://cdn.skypack.dev/@hotwired/turbo@7";
      </script>
    </head>
  \"\"\"
"""
  template_http_views_pages_welcome_welcome_page_nim = """import std/asyncdispatch
import basolato/view
import basolato/core/base
import ../../layouts/app/app_layout
import ../../layouts/app/app_layout_model
import ../../layouts/head/head_layout_model
import ../../templates/welcome/welcome_template
import ../../templates/welcome/welcome_template_model


proc welcomePageView*(context: Context):Future[Component] {.async.} =
  discard context
  let title = "Basolato " & BasolatoVersion
  let templateModel = WelcomeTemplateModel.new(title)
  let body = welcomeTemplate(templateModel)
  let headLayoutModel = HeadLayoutModel.new(title)
  let appLayoutModel = AppLayoutModel.new(headLayoutModel)
  return appLayout(appLayoutModel, body)
"""
  template_http_views_templates_welcome_welcome_template_model_nim = """type WelcomeTemplateModel* = object
  title*: string


proc new*(_: type WelcomeTemplateModel, title: string): WelcomeTemplateModel =
  return WelcomeTemplateModel(title: title)
"""
  template_http_views_templates_welcome_welcome_template_nim = """import basolato/view
import ./welcome_template_model


proc welcomeTemplate*(model: WelcomeTemplateModel): Component =
  let style = styleTmpl(Css, \"\"\"
    <style>
      body {
        background-color: black;
      }

      article {
        margin: 16px;
      }

      .title {
        color: goldenrod;
        text-align: center;
      }

      .topImage {
        background-color: gray;
        text-align: center;
      }

      .goldFont {
        color: goldenrod;
      }

      .whiteFont {
        color: silver;
      }

    </style>
  \"\"\")

  tmpl\"\"\"
    $(style)
    <link rel="stylesheet" href="http://cdn.jsdelivr.net/gh/highlightjs/cdn-release@9.17.1/build/styles/dracula.min.css">
    <script src="http://cdn.jsdelivr.net/gh/highlightjs/cdn-release@9.17.1/build/highlight.min.js"></script>
    <article>
      <section>
        <h1 class="$(style.element("title"))">Nim $(model.title) is successfully running!!!</h1>
        <div class="$(style.element("topImage"))">
          <img
            src="/basolato.svg"
            alt="nim-logo"
            style="height: 40vh"
          >
        </div>
      </section>
    </article>
    <article>
      <section>
        <h2 class="$(style.element("goldFont"))">
          Full-stack Web Framewrok for Nim
        </h2>
        <p class="$(style.element("whiteFont"))">
          <i>—utilitas, firmitas et venustas (utility, strength and beauty)— by De architectura / Marcus Vitruvius Pollio</i>
        </p>
        <div class="$(style.element("whiteFont"))">
          <ul>
            <li>Easy syntax as Python thanks to Nim</li>
            <li>Develop as easy as Ruby on Rails</li>
            <li>Stably structure as Symfony(PHP)</li>
            <li>Including easy query builder as Laravel(PHP)</li>
            <li>Run fast and light as Go and Rust</li>
            <li>This is the fastest full-stack web framework in the world</li>
          </ul>
        </div>
      </section>
    </article>
  \"\"\"
"""
  template_models_README_md = """
Domain Model
===

Domain model consists `Entity`, `Service` , `RepositoryInterface` and `Repository`.  
You can create domain model by command `ducere make model {domain name}`

```
user
├── user_entity.nim
├── user_repository_interface.nim
├── user_service.nim
└── user_value_objects.nim
```

## Value Object
Value object difines a behaviour of value.

```nim
type UserName* = ref object
  value:string

proc new*(_:type UserName, value:string):UserName =
  if isEmptyOrWhitespace(value):
    raise newException(Exception, "Name can't be blank")
  if value.len == 0:
    raise newException(Exception, "Name can't be blank")
  if value.len > 11:
    raise newException(Exception, "Name should be shorter than 10")
  return UserName(value:value)

proc `$`*(self:UserName):string =
  return this.value
```

## Entity
Entity is object which is a substance of business logic. In a simple application it is the same of a database table, but in a complex application it is represented as multiple tables joined together.

```nim
import ../value_objects

type User* = ref object
  id*: UserId
  name*: UserName
  email*: Email
  password*: Password

proc new*(typ:type User, id:UserId, name:UserName, email:Email, password:Password):User =
  return User(
    id:id,
    name:name,
    email:email,
    password:password,
    auth:auth
  )
```

## Repository Interface
The Repository Interface prevents the Repository knowledge from leaking to Service by executing the Repository's methods through the Di Container.

```nim
import asyncdispatch
import user_value_objects
import user_entity

type IUserRepository* = tuple
  getUserById: proc(id:UserId):Future[User]
  insert: proc(user:User):Future[int]
  save: proc(user:User):Future[void]
  delete: proc(user:User):Future[void]
```
"""
  template_models_aggregates_README_md = """
Aggregates
===

This directory contains the write-side domain models.
An aggregate represents one business boundary and keeps the rules that must remain consistent inside that boundary.

## Responsibilities

- Model business state for one boundary
- Enforce invariants and state transitions close to the model
- Keep construction logic such as IDs, timestamps, and defaults inside `new`
- Separate persistence concerns from domain behavior
- Expose repository interfaces for loading and saving
- Move cross-aggregate coordination to a service when needed

## Implementation Guidelines

- Use `vo` types for business values
- Gather creation inputs into a dedicated draft or parameter object when the constructor would otherwise become too large
- Initialize generated values such as timestamps, IDs, and hashes inside `new`
- Put entity definitions in `*_entity.nim`
- Put repository contracts in `*_repository_interface.nim`
- Put cross-aggregate rules in `*_service.nim` when needed
- Keep file names aligned with the aggregate name

## How To Think About It

- If a rule changes the meaning or validity of the aggregate, keep it here
- If a rule coordinates multiple aggregates, move it to a service
- If a value should never be represented as a raw primitive in this domain, model it as a `vo`

## Do Not Put Here

- SQL
- DAO
- View-oriented data
- Request-local `Context`
- JSON assembly
"""
  template_models_dto_README_md = """
DTO - Data Transfer Object
===

This directory contains read-side data transfer types.
Each DTO defines the shape of data returned for a page, a list, a detail view, or another read-only boundary.

## Responsibilities

- Package results fetched from databases or external APIs into a UI-friendly shape
- Represent retrieval results at the page or fragment level
- Serve as the return type of read-side query objects and be passed to templates or the corresponding layout/template/component models
- Keep the minimal transformation needed for display inside `new`
- Stay focused on read-side composition and avoid business mutation rules

## Implementation Guidelines

- Place one display unit in one DTO file
- Compose small DTOs when the view needs nested data
- Normalize DB strings and timestamps into display-friendly types inside `new`
- Define query contracts around use cases such as `findById`, `list`, or `count`
- Let list-style queries accept paging information such as `offset`, `limit`, or cursor values
- Keep DTO fields primitive or DTO-only so they stay easy to serialize and render

## How To Think About It

- If the data is only needed to render a page or fragment, it likely belongs here
- If the data is a business concept that can be changed, it likely belongs in aggregates or value objects
- If the data combines multiple sources for display, assemble it here

## Do Not Put Here

- Aggregate update logic
- Repository write operations
- Domain rule validation
- DB mutation logic
- `Context`-dependent access
"""
  template_models_vo_README_md = """
Value Objects
===

This directory contains values with domain meaning.
Use it to avoid passing raw `string` or `int` values around when the value carries business rules, identity, or intent.

## Responsibilities

- Give values a clear domain meaning
- Hold creation rules and validation rules when needed
- Provide comparison and conversion behavior
- Act as a safe input boundary for aggregates and services
- Keep invariants close to the value itself

## Implementation Guidelines

- Create one file per value
- Keep the internal field to a single `value`
- Put creation logic inside `new`
- Define multiple `new` overloads when needed
- Prefer explicit constructors over public field mutation
- Add equality or formatting helpers only when the type needs them

## How To Think About It

- If a primitive type can be invalid in your domain, wrap it in a value object
- If two values look similar but should not be interchangeable, give them different types
- If a value needs validation or transformation, keep that logic here instead of spreading it across callers

## Common Patterns

- Identifier values should enforce non-empty or generated input rules
- Meaning-specific strings should be separated by purpose, not by storage format
- Plain text and secured text should be modeled as different types

## Do Not Put Here

- SQL
- DAO
- DTO
- View-specific formatting
- Request-local data
"""
  template_usecases_README_md = """
Usecases
===

The `Usecase` is the layer that assembles the business logic by calling the `value object`, `entity`, `domain service`, `repository`, and `query service`.

## Example

```nim
import asyncdispatch, json, options
import ../../di_container
import ../../models/user/user_value_objects
import ../../models/user/user_entity
import ../../models/user/user_repository_interface
import ../../models/user/user_service

type SigninUsecase* = ref object
  repository: IUserRepository
  service: UserService

proc new*(typ:type SigninUsecase):SigninUsecase =
  return SigninUsecase(
    repository: di.userRepository,
    service: UserService.new(di.userRepository)
  )

proc run*(self:SigninUsecase, email, password:string):Future[JsonNode] {.async.} =
  let email = Email.new(email)
  let userOpt = await self.repository.getUserByEmail(email)
  let errorMsg = "user is not found"
  if not userOpt.isSome():
    raise newException(Exception, errorMsg)
  let user = userOpt.get
  let password = Password.new(password)
  if self.service.isMatchPassword(password, user):
    return %*{
      "id": $user.id,
      "name": $user.name,
      "auth": user.auth.get()
    }
  else:
    raise newException(Exception, errorMsg)
```
"""
  template_config_database_nim = """
import allographer/connection
import ./env


let rdb* = dbOpen(
  Sqlite3, # SQLite3 or MySQL or MariaDB or PostgreSQL or SurrealDB
  DB_URL,
  maxConnections = 1,
  timeout = 30,
  shouldDisplayLog = true,
  shouldOutputLogFile = false,
  logDir = "./logs",
)
"""
  template_config_env_nim = """
import std/strutils
import basolato/core/env


type AppEnvType* = enum
  Test = "test",
  Develop = "develop",
  Staging = "staging",
  Production = "production"


func parseAppEnv*(raw: string): AppEnvType =
  case raw.strip().toLowerAscii()
  of "test":
    AppEnvType.Test
  of "develop":
    AppEnvType.Develop
  of "staging":
    AppEnvType.Staging
  of "production":
    AppEnvType.Production
  else:
    raise newException(ValueError, "APP_ENV must be test|develop|staging|production")


let APP_ENV* = parseAppEnv(optionalEnv("APP_ENV", "develop"))
let SECRET_KEY* = requireEnv("SECRET_KEY")
let DB_URL* = requireEnv("DB_URL")
"""
  template_database_develop_sh = """
# This file is executed from the root directory of the project.
nim c -d:reset --threads:off ./database/migrations/migrate.nim
nim c --threads:off ./database/seeders/develop

./database/migrations/migrate
./database/seeders/develop
"""
  template_database_staging_sh = """
# This file is executed from the root directory of the project.
nim c -d:reset --threads:off ./database/migrations/migrate.nim
nim c --threads:off ./database/seeders/staging

./database/migrations/migrate
./database/seeders/staging
"""
  template_database_production_sh = """
# This file is executed from the root directory of the project.
nim c -d:reset --threads:off ./database/migrations/migrate.nim
nim c --threads:off ./database/seeders/production

./database/migrations/migrate
./database/seeders/production
"""
  template_database_migrations_README_md = """
Migrations
===
Migrations are Database table difinition.
"""
  template_database_migrations_data_create_sample_table_nim = """
import std/json
import allographer/schema_builder
from ../../../config/database import rdb

proc createSampleTable*() =
  rdb.create([
    table("sample", [
      Column.increments("id"),
      Column.string("name"),
    ])
  ])
"""
  template_database_migrations_migrate_nim = """
import std/asyncdispatch
import allographer/schema_builder
from ../../config/database import rdb
import ./data/create_sample_table

proc main() =
  createSampleTable()

main()
rdb.createSchema().waitFor()
"""
  template_database_schema_nim = """
import std/json

type SampleTable* = object
  ## sample
  id*: int
  name*: string
"""
  template_database_seeders_README_md = """
Seeders
===
Seeders is used to create default data of database.
"""
  template_database_seeders_data_sample_seeder_nim = """
import std/asyncdispatch
import std/json
import std/strformat
import allographer/query_builder
from ../../../config/database import rdb

proc sampleSeeder*() {.async.} =
  rdb.seeder("sample"):
    var data: seq[JsonNode]
    for i in 1..10:
      data.add(%*{
        "id": i,
        "name": &"sample{i}"
      })
    rdb.table("sample").insert(data).await
"""
  template_database_seeders_develop_nim = """
import std/asyncdispatch
import ./data/sample_seeder

proc main() {.async.} =
  sampleSeeder().await

main().waitFor()
"""
  template_database_seeders_production_nim = """
import std/asyncdispatch


proc main() {.async.} =
  discard

main().waitFor()
"""
  template_database_seeders_staging_nim = """
import std/asyncdispatch


proc main() {.async.} =
  discard

main().waitFor()
"""
  template_main_nim = """
import std/os
# framework
import basolato
# middleware
import ./app/http/middlewares/session_middleware
import ./app/http/middlewares/set_headers_middleware
# controller
import ./app/http/controllers/welcome_controller


let routes = @[
  Route.group("", @[
    Route.group("", @[
      Route.get("/", welcome_controller.welcomePage),
    ])
    .middleware(session_middleware.checkCsrfToken)
    .middleware(session_middleware.sessionFromCookie),

    Route.group("/api", @[
      Route.get("/index", welcome_controller.indexApi),
    ])
    .middleware(set_headers_middleware.setSecureHeaders)
  ])
  .middleware(set_headers_middleware.setCorsHeaders)
]

let settings = Settings.new()

serve(routes, settings)
"""
  template_public_basolato_svg = """
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 20010904//EN"
              "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">

<svg xmlns="http://www.w3.org/2000/svg"
     width="5.55556in" height="5.55556in"
     viewBox="0 0 500 500">
  <path id="up"
        fill="black" stroke="black" stroke-width="1"
        d="M 250.45,68.36
           C 250.45,68.36 135.36,132.36 135.36,132.36
             135.36,132.36 199.38,248.62 199.38,248.62
             199.38,248.62 300.26,248.55 300.26,248.55
             300.26,248.55 364.00,133.25 364.00,133.25
             364.00,133.25 250.45,68.36 250.45,68.36 Z" />
  <path id="right"
        fill="black" stroke="black" stroke-width="1"
        d="M 302.67,249.67
           C 302.67,249.67 365.33,364.00 365.33,364.00
             365.33,364.00 482.33,295.67 482.33,295.67
             482.33,295.67 482.33,200.83 482.33,200.83
             482.33,200.83 366.38,134.29 366.38,134.29
             366.38,134.29 302.67,249.67 302.67,249.67 Z" />
  <path id="under"
        fill="black" stroke="black" stroke-width="1"
        d="M 199.67,251.96
           C 199.67,251.96 136.00,366.67 136.00,366.67
             136.00,366.67 250.00,430.33 250.00,430.33
             250.00,430.33 363.00,365.00 363.00,365.00
             363.00,365.00 300.33,251.96 300.33,251.96
             300.33,251.96 199.67,251.96 199.67,251.96 Z" />
  <path id="left"
        fill="black" stroke="black" stroke-width="1"
        d="M 133.00,134.00
           C 133.00,134.00 17.33,198.67 17.33,198.67
             17.33,198.67 17.33,300.33 17.33,300.33
             17.33,300.33 133.67,365.33 133.67,365.33
             133.67,365.33 197.33,251.00 197.33,251.00
             197.33,251.00 133.00,134.00 133.00,134.00 Z" />
  <path id="break"
        fill="none" stroke="white" stroke-width="3"
        d="M 134.00,133.00
           C 134.00,133.00 198.67,250.67 198.67,250.67
             198.67,250.67 134.96,365.83 134.96,365.83M 365.00,133.62
           C 365.00,133.62 301.33,250.33 301.33,250.33
             301.33,250.33 364.17,364.50 364.17,364.50M 198.67,250.33
           C 198.67,250.33 301.33,250.33 301.33,250.33" />
  <path id="outer"
        fill="none" stroke="goldenrod" stroke-width="8"
        d="M 250.55,63.70
           C 250.55,63.70 13.33,197.00 13.33,197.00
             13.33,197.00 13.03,302.79 13.03,302.79
             13.03,302.79 250.64,434.91 250.64,434.91
             250.64,434.91 486.06,298.48 486.06,298.48
             486.06,298.48 485.91,198.61 485.91,198.61
             485.91,198.61 250.55,63.70 250.55,63.70 Z" />
</svg>
"""
  template_public_favicon_ico = ""
  template_resources_lang_en_validation_json = """
{
  "accepted": "The :attribute must be accepted.",
  "after": "The :attribute must be a date after :date.",
  "after_or_equal": "The :attribute must be a date after or equal to :date.",
  "alpha": "The :attribute may only contain letters.",
  "alpha_dash": "The :attribute may only contain letters, numbers, dashes and underscores.",
  "alpha_num": "The :attribute may only contain letters and numbers.",
  "array": "The :attribute must be an array.",
  "before": "The :attribute must be a date before :date.",
  "before_or_equal": "The :attribute must be a date before or equal to :date.",
  "between": {
    "numeric": "The :attribute must be between :min and :max.",
    "file": "The :attribute must be between :min and :max kilobytes.",
    "string": "The :attribute must be between :min and :max characters.",
    "array": "The :attribute must have between :min and :max items."
  },
  "boolean": "The :attribute field must be true or false.",
  "confirmed": "The :attribute confirmation does not match.",
  "date": "The :attribute is not a valid date.",
  "date_equals": "The :attribute must be a date equal to :date.",
  "different": "The :attribute and :other must be different.",
  "digits": "The :attribute must be :digits digits.",
  "digits_between": "The :attribute must be between :min and :max digits.",
  "distinct": "The :attribute field has a duplicate value.",
  "domain": "The :attribute must be a valid domain.",
  "email": "The :attribute must be a valid email address.",
  "ends_with": "The :attribute must be end with one of following :values.",
  "file": "The :attribute must be a file.",
  "filled": "The :attribute field must have a value.",
  "gt": {
    "numeric": "The :attribute must be greater than :value.",
    "file": "The :attribute must be greater than :value kilobytes.",
    "string": "The :attribute must be greater than :value characters.",
    "array": "The :attribute must have more than :value items."
  },
  "gte": {
    "numeric": "The :attribute must be greater than or equal :value.",
    "file": "The :attribute must be greater than or equal :value kilobytes.",
    "string": "The :attribute must be greater than or equal :value characters.",
    "array": "The :attribute must have :value items or more."
  },
  "image": "The :attribute must be an image.",
  "in": "The selected :attribute is invalid.",
  "in_array": "The :attribute field does not exist in :other.",
  "integer": "The :attribute must be an integer.",
  "json": "The :attribute must be a valid JSON string.",
  "lt": {
    "numeric": "The :attribute must be less than :value.",
    "file": "The :attribute must be less than :value kilobytes.",
    "string": "The :attribute must be less than :value characters.",
    "array": "The :attribute must have less than :value items."
  },
  "lte": {
    "numeric": "The :attribute must be less than or equal :value.",
    "file": "The :attribute must be less than or equal :value kilobytes.",
    "string": "The :attribute must be less than or equal :value characters.",
    "array": "The :attribute must not have more than :value items."
  },
  "max": {
    "numeric": "The :attribute may not be greater than :max.",
    "file": "The :attribute may not be greater than :max kilobytes.",
    "string": "The :attribute may not be greater than :max characters.",
    "array": "The :attribute may not have more than :max items."
  },
  "mimes": "The :attribute must be a file of type: :values.",
  "min": {
    "numeric": "The :attribute must be at least :min.",
    "file": "The :attribute must be at least :min kilobytes.",
    "string": "The :attribute must be at least :min characters.",
    "array": "The :attribute must have at least :min items."
  },
  "not_in": "The selected :attribute is invalid.",
  "not_regex": "The :attribute format is invalid.",
  "numeric": "The :attribute must be a number.",
  "present": "The :attribute field must be present.",
  "password": "The :attribute must be at least 8 chars containing upper case letter and lower case letter and number.",
  "regex": "The :attribute format is invalid.",
  "required": "The :attribute field is required.",
  "required_if": "The :attribute field is required when :other is :value.",
  "required_unless": "The :attribute field is required unless :other is in :values.",
  "required_with": "The :attribute field is required when :values is present.",
  "required_with_all": "The :attribute field is required when :values are present.",
  "required_without": "The :attribute field is required when :values is not present.",
  "required_without_all": "The :attribute field is required when none of :values are present.",
  "same": "The :attribute and :other must match.",
  "size": {
    "numeric": "The :attribute must be :size.",
    "file": "The :attribute must be :size kilobytes.",
    "string": "The :attribute must be :size characters.",
    "array": "The :attribute must contain :size items."
  },
  "starts_with": "The :attribute must be start with one of following :values.",
  "timestamp": "The :attribute is not a valid timestamp.",
  "url": "The :attribute format is invalid.",
  "uuid": "The :attribute must be a valid UUID."
}
"""
  template_resources_lang_ja_validation_json = """
{
  "accepted": ":attributeを承認してください。",
  "after": ":attributeには、:dateより後の日付を指定してください。",
  "after_or_equal": ":attributeには、:date以降の日付を指定してください。",
  "alpha": ":attributeはアルファベットのみがご利用できます。",
  "alpha_dash": ":attributeはアルファベットとダッシュ(-)及び下線(_)がご利用できます。",
  "alpha_num": ":attributeはアルファベット数字がご利用できます。",
  "array": ":attributeは配列でなくてはなりません。",
  "before": ":attributeには、:dateより前の日付をご利用ください。",
  "before_or_equal": ":attributeには、:date以前の日付をご利用ください。",
  "between": {
    "numeric": ":attributeは、:minから:maxの間で指定してください。",
    "file": ":attributeは、:min kBから、:max kBの間で指定してください。",
    "string": ":attributeは、:min文字から、:max文字の間で指定してください。",
    "array": ":attributeは、:min個から:max個の間で指定してください。"
  },
  "boolean": ":attributeは、trueかfalseを指定してください。",
  "confirmed": ":attributeと、確認フィールドとが、一致していません。",
  "date": ":attributeには有効な日付を指定してください。",
  "date_equals": ":attributeには、:dateと同じ日付けを指定してください。",
  "different": ":attributeと:otherには、異なった内容を指定してください。",
  "digits": ":attributeは:digits桁で指定してください。",
  "digits_between": ":attributeは:min桁から:max桁の間で指定してください。",
  "distinct": ":attributeには異なった値を指定してください。",
  "domain": ":attributeには、有効なドメインを指定してください。",
  "email": ":attributeには、有効なメールアドレスを指定してください。",
  "ends_with": ":attributeには、:valuesのどれかで終わる値を指定してください。",
  "file": ":attributeにはファイルを指定してください。",
  "filled": ":attributeに値を指定してください。",
  "gt": {
    "numeric": ":attributeには、:valueより大きな値を指定してください。",
    "file": ":attributeには、:value kBより大きなファイルを指定してください。",
    "string": ":attributeは、:value文字より長く指定してください。",
    "array": ":attributeには、:value個より多くのアイテムを指定してください。"
  },
  "gte": {
    "numeric": ":attributeには、:value以上の値を指定してください。",
    "file": ":attributeには、:value kB以上のファイルを指定してください。",
    "string": ":attributeは、:value文字以上で指定してください。",
    "array": ":attributeには、:value個以上のアイテムを指定してください。"
  },
  "image": ":attributeには画像ファイルを指定してください。",
  "in": "選択された:attributeは正しくありません。",
  "in_array": ":attributeには:otherの値を指定してください。",
  "integer": ":attributeは整数で指定してください。",
  "json": ":attributeには、有効なJSON文字列を指定してください。",
  "lt": {
    "numeric": ":attributeには、:valueより小さな値を指定してください。",
    "file": ":attributeには、:value kBより小さなファイルを指定してください。",
    "string": ":attributeは、:value文字より短く指定してください。",
    "array": ":attributeには、:value個より少ないアイテムを指定してください。"
  },
  "lte": {
    "numeric": ":attributeには、:value以下の値を指定してください。",
    "file": ":attributeには、:value kB以下のファイルを指定してください。",
    "string": ":attributeは、:value文字以下で指定してください。",
    "array": ":attributeには、:value個以下のアイテムを指定してください。"
  },
  "max": {
    "numeric": ":attributeには、:max以下の数字を指定してください。",
    "file": ":attributeには、:max kB以下のファイルを指定してください。",
    "string": ":attributeは、:max文字以下で指定してください。",
    "array": ":attributeは:max個以下指定してください。"
  },
  "mimes": ":attributeには:valuesタイプのファイルを指定してください。",
  "min": {
    "numeric": ":attributeには、:min以上の数字を指定してください。",
    "file": ":attributeには、:min kB以上のファイルを指定してください。",
    "string": ":attributeは、:min文字以上で指定してください。",
    "array": ":attributeには:min個以上指定してください。"
  },
  "not_in": "選択された:attributeは正しくありません。",
  "not_regex": ":attributeの形式が正しくありません。",
  "numeric": ":attributeには、数字を指定してください。",
  "present": ":attributeが存在していません。",
  "password": ":attributeは大文字小文字数字全て含む8文字以上にしてください。",
  "regex": ":attributeに正しい形式を指定してください。",
  "required": ":attributeは必ず指定してください。",
  "required_if": ":otherが:valueの場合、:attributeも指定してください。",
  "required_unless": ":otherが:valuesでない場合、:attributeを指定してください。",
  "required_with": ":valuesを指定する場合は、:attributeも指定してください。",
  "required_with_all": ":valuesを指定する場合は、:attributeも指定してください。",
  "required_without": ":valuesを指定しない場合は、:attributeを指定してください。",
  "required_without_all": ":valuesのどれも指定しない場合は、:attributeを指定してください。",
  "same": ":attributeと:otherには同じ値を指定してください。",
  "size": {
    "numeric": ":attributeは:sizeを指定してください。",
    "file": ":attributeのファイルは、:sizeキロバイトでなくてはなりません。",
    "string": ":attributeは:size文字で指定してください。",
    "array": ":attributeは:size個指定してください。"
  },
  "starts_with": ":attributeには、:valuesのどれかで始まる値を指定してください。",
  "timestamp": ":attributeには有効なタイムスタンプを指定してください。",
  "uploaded": ":attributeのアップロードに失敗しました。",
  "url": ":attributeに正しい形式を指定してください。",
  "uuid": ":attributeに有効なUUIDを指定してください。"
}
"""
  template_tests_test_sample_nim = """
import std/unittest

suite("sample"):
  test("sample test"):
    check true
"""

const templateFiles: array[46, TemplateFile] = [
  (".gitignore", template_gitignore),
  ("app/README.md", template_README_md),
  ("app/data_stores/dao/README.md", template_data_stores_dao_README_md),
  ("app/data_stores/repositories/README.md", template_data_stores_repositories_README_md),
  ("app/di_container.nim", template_di_container_nim),
  ("app/http/controllers/README.md", template_http_controllers_README_md),
  ("app/http/controllers/welcome_controller.nim", template_http_controllers_welcome_controller_nim),
  ("app/http/middlewares/README.md", template_http_middlewares_README_md),
  ("app/http/middlewares/session_middleware.nim", template_http_middlewares_session_middleware_nim),
  ("app/http/middlewares/set_headers_middleware.nim", template_http_middlewares_set_headers_middleware_nim),
  ("app/http/views/README.md", template_http_views_README_md),
  ("app/http/views/components/README.md", template_http_views_components_README_md),
  ("app/http/views/layouts/app/app_layout_model.nim", template_http_views_layouts_app_app_layout_model_nim),
  ("app/http/views/layouts/app/app_layout.nim", template_http_views_layouts_app_app_layout_nim),
  ("app/http/views/layouts/footer/footer_layout.nim", template_http_views_layouts_footer_footer_layout_nim),
  ("app/http/views/layouts/head/head_layout_model.nim", template_http_views_layouts_head_head_layout_model_nim),
  ("app/http/views/layouts/head/head_layout.nim", template_http_views_layouts_head_head_layout_nim),
  ("app/http/views/pages/welcome/welcome_page.nim", template_http_views_pages_welcome_welcome_page_nim),
  ("app/http/views/templates/welcome/welcome_template_model.nim", template_http_views_templates_welcome_welcome_template_model_nim),
  ("app/http/views/templates/welcome/welcome_template.nim", template_http_views_templates_welcome_welcome_template_nim),
  ("app/presenters/README.md", template_app_presenters_README_md),
  ("app/models/README.md", template_models_README_md),
  ("app/models/aggregates/README.md", template_models_aggregates_README_md),
  ("app/models/dto/README.md", template_models_dto_README_md),
  ("app/models/vo/README.md", template_models_vo_README_md),
  ("app/usecases/README.md", template_usecases_README_md),
  ("config/env.nim", template_config_env_nim),
  ("config/database.nim", template_config_database_nim),
  ("database/develop.sh", template_database_develop_sh),
  ("database/staging.sh", template_database_staging_sh),
  ("database/production.sh", template_database_production_sh),
  ("database/migrations/README.md", template_database_migrations_README_md),
  ("database/migrations/data/create_sample_table.nim", template_database_migrations_data_create_sample_table_nim),
  ("database/migrations/migrate.nim", template_database_migrations_migrate_nim),
  ("database/schema.nim", template_database_schema_nim),
  ("database/seeders/README.md", template_database_seeders_README_md),
  ("database/seeders/data/sample_seeder.nim", template_database_seeders_data_sample_seeder_nim),
  ("database/seeders/develop.nim", template_database_seeders_develop_nim),
  ("database/seeders/production.nim", template_database_seeders_production_nim),
  ("database/seeders/staging.nim", template_database_seeders_staging_nim),
  ("main.nim", template_main_nim),
  ("public/basolato.svg", template_public_basolato_svg),
  ("public/favicon.ico", template_public_favicon_ico),
  ("resources/lang/en/validation.json", template_resources_lang_en_validation_json),
  ("resources/lang/ja/validation.json", template_resources_lang_ja_validation_json),
  ("tests/test_sample.nim", template_tests_test_sample_nim),
]

proc normalized(content: string): string =
  if content.len == 0:
    return content
  result = content.strip(chars = {'\n'})
  result = result.replace("\\\"\\\"\\\"", "\"\"\"")
  result.add('\n')


proc ensureDir(targetDir: string) =
  if not dirExists(targetDir):
    createDir(targetDir)


proc createTemplateDirs(baseDir: string) =
  for relDir in templateDirs:
    ensureDir(baseDir / relDir)


proc writeTemplateFile(baseDir, relPath, content: string) =
  let targetPath = baseDir / relPath
  writeFile(targetPath, normalized(content))


proc writePackageNimble(baseDir, packageDir: string) =
  let nimble = """
# Package
version       = "0.1.0"
author        = "Anonymous"
description   = "A new awesome basolato package"
license       = "MIT"
srcDir        = "."
bin           = @["main"]
backend       = "c"

# Dependencies
requires "nim >= 2.0.0"
requires "https://github.com/itsumura-h/nim-basolato >= 0.15.0"
requires "allographer >= 0.32.0"
requires "interface_implements >= 0.2.2"
requires "faker >= 0.14.0"

task test, "run testament":
  echo staticExec("testament p \"./tests/test_*.nim\"")
  discard staticExec("find tests/ -type f ! -name \"*.*\" -delete 2> /dev/null")
"""
  writeTemplateFile(baseDir, packageDir & ".nimble", nimble)


proc writeEmptyPlaceholders(baseDir: string) =
  setFilePermissions(
    baseDir / "database/develop.sh",
    {fpUserRead, fpUserWrite, fpUserExec, fpGroupRead, fpGroupExec, fpOthersRead, fpOthersExec}
  )


proc create(dirPath, packageDir: string): int =
  let isCurrentDir = dirPath == getCurrentDir()
  try:
    if not isCurrentDir:
      createDir(dirPath)

    createTemplateDirs(dirPath)
    for item in templateFiles:
      writeTemplateFile(dirPath, item.path, item.content)

    writePackageNimble(dirPath, packageDir)
    discard makeConfig(dirPath)
    writeEmptyPlaceholders(dirPath)

    styledEcho(fgBlack, bgGreen, "[Success] Created project in " & dirPath, resetStyle)
    return 0
  except:
    echo getCurrentExceptionMsg()
    if not isCurrentDir and dirExists(dirPath):
      removeDir(dirPath)
    return 1


proc new*(args: seq[string]): int =
  ## Create new project
  var
    message: string
    packageDir: string
    dirPath: string

  try:
    if args[0] == ".":
      dirPath = getCurrentDir()
      packageDir = splitPath(dirPath).tail
    else:
      packageDir = args[0]
      dirPath = getCurrentDir() & "/" & packageDir
      if isDirExists(dirPath):
        return 0
  except:
    message = "Missing args"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return 0

  message = "create project " & dirPath
  return create(dirPath, packageDir)

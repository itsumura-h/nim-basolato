# Basolato Design Guide

This document summarizes the usage and design policies for read-side (GET) and write-side (POST) in Basolato, following the flow of request processing. It is divided into two major categories: "Read-side" and "Write-side," organized according to the execution order starting from `main.nim`.

## 1. Read-side

### 1.1 Overall View

Basolato's GET read-side is constructed according to the following flow:

```text
Route.get
  -> controller
  -> pageView(context)
  -> templateModel.new(context)
  -> di container
  -> DAO
  -> DTO
  -> template / component
  -> appLayoutModel.new(context, title, body)
  -> appLayout(layoutModel)
  -> render(response)
```

The purpose of this flow is to clearly separate the HTTP entry point, screen composition, data acquisition, and rendering.

### 1.2 Route.get

The starting point for read-side processing is `Route.get(...)`. GET requests are passed from the router to the controller.

```nim
Route.get("/some-page", some_controller.somePage)
```

The role here is simple:

- Map URLs to controllers
- Insert middleware
- Define the entry point for GET screen display processing

`Route.get` itself does not perform screen construction. The responsibility for the screen is always passed to the controller and subsequent layers.

### 1.3 Controller

The controller is the HTTP boundary. In Basolato's read-side, controllers should be kept thin.

### 3.1 Naming

The naming of read-side controllers should follow these basics:

- Screen display: `*Page`
- Detail display: `show`
- List display: `index`

Examples:

- `signInPage`
- `signUpPage`
- `settingPage`
- `show`
- `index`

### 3.2 Responsibilities

The responsibilities of the controller are limited to the following:

- Receive `Context`
- Call the corresponding pageView
- Return a `Response` using `render(...)`
- Perform authentication, authorization, and redirect decisions if necessary

The standard form is as follows:

```nim
proc somePage*(context: Context): Future[Response] {.async.} =
  let page = somePageView(context).await
  return render(page)
```

Responsibilities the controller should NOT have:

- HTML construction
- Details of DAO calls
- Rendering logic per template
- Data formatting at the component level

### 1.4 PageView

The pageView is called after the controller. The pageView is the composition layer for the full page.

### 4.1 Naming

We recommend `*PageView` for the View entry point that assembles the full HTML.

Examples:

- `loginPageView`
- `homePageView`
- `articlePageView`

By separating `*Page` and `*PageView`, you can distinguish between the HTTP entry point and the View entry point.

### 4.2 Responsibilities

The responsibilities of the pageView are as follows:

- Receive the request-local `Context`
- Decide which template to use
- Compose multiple templates if necessary
- Create the body
- Finally apply the layout

The standard form is as follows:

```nim
proc somePageView*(context: Context): Future[Component] {.async.} =
  let model = SomeTemplateModel.new(context).await
  let body = someTemplate(model)
  let layoutModel = AppLayoutModel.new(context, "Page Title", body).await
  return appLayout(layoutModel)
```

Responsibilities the pageView should NOT have:

- Details of DAO implementation
- Fine-grained rendering inside templates
- Logic inside components

### 4.3 Single-template pages and Multi-template pages

Single-template page:

```text
pageView(context)
  -> TemplateModel.new(context)
  -> template(model)
  -> AppLayoutModel.new(...)
  -> appLayout(...)
```

Multi-template page:

```text
pageView(context)
  -> MainSectionTemplateModel.new(context)
  -> mainSectionTemplate(model)
  -> SidebarTemplateModel.new(context)
  -> sidebarTemplate(model)
  -> pageBody(mainSection, sidebar)
  -> AppLayoutModel.new(...)
  -> appLayout(...)
```

### 1.5 TemplateModel

The template model is the central element following the pageView. The template model is responsible for assembling the read-side of the screen.

### 5.1 Naming

The display data corresponding to a template is called `*TemplateModel`.

Examples:

- `LoginTemplateModel`
- `FeedTemplateModel`
- `PopularTagsTemplateModel`

A template model basically has a 1-to-1 relationship with a template.

### 5.2 Responsibilities

The responsibilities of the template model are as follows:

- Retrieve request-local values from `Context`
- Use necessary DAOs through the `di container`
- Receive DTOs returned from DAOs
- Convert DTOs into display data
- Assemble models for components
- Prepare the data so the template can render it directly

Examples of values that should be aggregated in the template model:

- Authentication state
- CSRF token
- old input
- validation error
- flash message
- pagination information
- list data used within the template

The template model is the meeting point for request-local values and values retrieved from the database.

### 1.6 DI Container

The `di container` is used for dependency resolution inside the template model.

### 6.1 Role

The role of the `di container` is as follows:

- Aggregate and expose DAO implementations
- Prevent the template model from directly instantiating concrete implementations
- Facilitate switching between real databases and test doubles

The template model accesses necessary DAOs through the `di container`.

```nim
proc new*(_: type SomeTemplateModel, context: Context): Future[SomeTemplateModel] {.async.} =
  let dtoList = di.someDao.fetchList().await
  return SomeTemplateModel.new(dtoList)
```

### 6.2 Principles

- The template model is the primary place allowed to touch the `di container`.
- Do not resolve DAOs directly from the controller.
- Do not use `di` directly from templates or components.

### 1.7 DAO

Beyond the `di container` lies the DAO.

DAO stands for `Data Access Object`.

### 7.1 Role

The DAO is the data acquisition boundary for read-only access. In Basolato, it is treated specifically for the read-side.

The main responsibilities of the DAO are as follows:

- Retrieve necessary data from the database
- Perform joins, batching, and aggregation
- Return DTOs suitable for read-only purposes
- Retrieve data in bulk per template to avoid N+1 issues

### 7.2 Design Policy

- Design DAOs per template, not per table.
- Avoid over-dividing DAOs per component.
- Avoid retrieval inside loops within templates.

For example, on a list screen, we recommend a design where the template model calls a list DAO once and receives the required number of items in bulk.

```text
TemplateModel
  -> ArticleListDao
  -> seq[ArticleListDto]
  -> seq[FeedArticleComponentModel]
  -> template / component
```

### 7.3 Responsibilities the DAO should NOT have:

- String formatting for HTML
- Rendering requirements of components
- Update logic of the domain
- Dependence on HTTP requests

### 1.8 DTO

The DAO returns a DTO.

DTO stands for `Data Transfer Object`.

### 8.1 Role

A DTO is a transport object used to pass the results retrieved by the DAO to the template model.

The main roles of a DTO are as follows:

- Represent database rows or join results in an easy-to-use format
- Bridge the DAO and the template model
- Avoid direct coupling between the domain model and the View model

### 8.2 Design Policy

- Compose mainly of primitives.
- Hold only values necessary for read-only purposes.
- Keep behavior to a minimum.
- Do not bring in HTML rendering requirements.

A DTO is not the final form of screen rendering. The final form is handled by the template model or component model.

The division of labor is as follows:

- DTO: Transporting retrieval results
- TemplateModel: Reconstructing DTOs for rendering
- Template: Rendering the reconstructed model

### 1.9 Template

The template renders HTML based on the display data prepared by the template model.

### 9.1 Naming

Functions that render HTML fragments are named `*Template`.

Examples:

- `loginTemplate`
- `feedTemplate`
- `popularTagsTemplate`

### 9.2 Responsibilities

The responsibilities of the template are as follows:

- Output values from the model
- Perform conditional branching
- Perform repeated rendering
- Call components

The ideal form is as follows:

```nim
proc someTemplate*(model: SomeTemplateModel): Component =
  tmpl"""
    <section>
      <h1>$(model.title)</h1>
    </section>
  """
```

### 9.3 Responsibilities the template should NOT bring in:

- Direct dependence on `Context`
- DAO calls
- Resolving state per request
- Domain logic

The goal is for the template to just receive a model and render it.

### 1.10 Component

Components are small, pure UI elements reused within templates.

### 10.1 Naming

- Component input: `*ComponentModel`
- Component rendering function: `*Component`

### 10.2 Responsibilities

- Components focus on rendering.
- Component input is completed on the template model side.
- Do not call DAOs from components.
- Do not read `Context` from components.

The recommended dependency direction is as follows:

```text
page
  -> template model
  -> component model
  -> template
  -> component
```

### 1.11 AppLayoutModel

After the body is created in a template or page, `AppLayoutModel` is used to assemble data for the common layout.

### 11.1 Naming

- `AppLayoutModel`
- `HeadLayoutModel`
- `NavbarLayoutModel`

### 11.2 Responsibilities

`AppLayoutModel` aggregates common information required for layout rendering.

- title
- model for head
- model for navbar
- body
- footer or meta information if necessary

In other words, the page creates the body, and the layout model aggregates common components for the entire page.

### 1.12 AppLayout

`appLayout` renders the entire HTML document by receiving an `AppLayoutModel`.

### 12.1 Naming

- `appLayout`
- `headLayout`
- `navbarLayout`

### 12.2 Responsibilities

`appLayout` generates the entire HTML document.

- `<!DOCTYPE html>`
- `<html>`
- `<head>`
- Common navigation
- body
- footer

This separates the page into "body construction" and the layout into "shell construction."

### 1.13 render

Finally, the controller calls `render(page)`, which converts the `Component` into a `Response`.

```nim
proc somePage*(context: Context): Future[Response] {.async.} =
  let page = somePageView(context).await
  return render(page)
```

`render` is the final stage returned as an HTTP response, and the View construction responsibility should be completed before this point.

### 1.14 Summary of Naming Conventions

In Basolato's read-side, we recommend aligning naming for each role:

- controller: `*Page`, `show`, `index`
- page: `*PageView`
- template model: `*TemplateModel`
- template: `*Template`
- component model: `*ComponentModel`
- component: `*Component`
- layout model: `*LayoutModel`
- layout: `*Layout`

In Basolato, the pair of `XxxModel + xxx function` is treated as the basic unit of a View.

### 1.15 Patterns to Avoid

In Basolato's read-side, it is desirable to avoid the following writing styles:

- Constructing HTML directly in the controller
- Calling `di.someDao` directly from the controller
- Reading `Context` directly from templates
- Calling DAOs from templates or components
- Calling DAOs inside loops within templates
- Retrieving data per component
- Using DTOs directly as the public API for templates
- Reading per-request state globally

These obscure responsibilities and reduce concurrent request safety and maintainability.

### 1.16 Summary of Design Principles

Basolato's GET read-side is designed based on the following principles:

- `Route.get` remains just as an entry point definition.
- Controllers should be kept thin.
- pageView is responsible for full-page composition.
- template model is responsible for read-side acquisition and formatting.
- di container is limited to being the entry point for dependency resolution.
- DAO is designed as a retrieval boundary for read-only access.
- DTO is limited to transporting retrieval results.
- Templates lean towards pure rendering.
- Components are limited to pure UI.
- appLayoutModel and appLayout are responsible for the common shell.
- `Context` is explicitly passed as request-local.

In short, the read-side design of Basolato is based on the separation of responsibilities: `Route.get -> controller -> pageView -> templateModel -> di container -> DAO -> DTO -> template/component -> appLayoutModel -> appLayout -> render`.

## 2. Write-side

### 2.1 Overall View

Basolato's POST write-side is constructed according to the following flow:

```text
Route.post
  -> controller
  -> validation
  -> usecase
  -> value object
  -> aggregate / entity
  -> domain service
  -> repository
  -> di container
  -> redirect / error handling
```

The purpose of this flow is to separate HTTP input, business rules, and persistence. The controller receives input, the usecase advances the update usecase, and the aggregate and repository handle domain consistency and persistence.

### 2.2 Route.post

The starting point for write-side processing is `Route.post(...)`. POST requests are passed from the router to the controller.

```nim
Route.post("/login", auth_controller.signIn)
Route.post("/register", auth_controller.signUp)
Route.post("/settings", setting_controller.updateSettings)
```

The roles here are as follows:

- Map URLs to update controllers
- Insert middleware
- Define the entry point for POST update processing

`Route.post` itself does not hold business logic. Actual update processing is passed to the controller and subsequent layers.

### 2.3 Controller

POST controllers are also HTTP boundaries. Like read-side controllers, they should be kept thin.

### 19.1 Naming

The naming of write-side controllers should be based on verbs corresponding to HTTP actions.

Examples:

- `signIn`
- `signUp`
- `signOut`
- `updateSettings`
- `follow`

### 19.2 Responsibilities

The responsibilities of the write-side controller are as follows:

- Receive input from `Context`
- Perform request validation
- If validation fails, save flash messages or old input and redirect
- Call the usecase
- If successful, perform session updates or redirects
- If an exception occurs, save the error and redirect

The standard form for `signIn` / `signUp` can be organized as follows:

```nim
proc someAction*(context: Context): Future[Response] {.async.} =
  let validation = RequestValidation.new(context)
  # validate...

  if validation.hasErrors():
    context.storeValidationResult(validation).await
    return redirect("/some-form")

  let someValue = context.params.getStr("someValue")

  try:
    let usecase = SomeUsecase.new()
    let result = usecase.invoke(someValue).await
    # session / flash / redirect
    return redirect("/")
  except:
    let error = getCurrentExceptionMsg()
    context.storeError(error).await
    return redirect("/some-form")
```

Responsibilities the controller should NOT have:

- Implementation of internal rules for VOs or aggregates
- Repository SQL or DB update details
- Decision logic of domain services
- Central responsibility for business flows spanning multiple repositories

### 2.4 Usecase

The usecase is the central element of the update flow following the controller.

### 20.1 Naming

The application layer for the write-side is called `*Usecase`.

Examples:

- `LoginUsecase`
- `RegisterUsecase`
- `UpdateSettingUsecase`
- `FollowUsecase`

### 20.2 Responsibilities

The responsibilities of the usecase are as follows:

- Put primitive inputs received from the controller onto the business flow
- Convert strings into VOs
- Advance business processing using repositories or services
- Create or restore aggregates/entities
- Finally request saving to the repository
- Assemble minimal return values to be returned to the controller

The update flow based on `signUp` is as follows:

```text
Route.post("/register")
  -> auth_controller.signUp(context)
  -> RegisterUsecase.new()
  -> RegisterUsecase.invoke(name, email, password)
  -> UserName.new / Email.new / Password.new
  -> repository.getUserByEmail(email)
  -> DraftUser.new(...)
  -> repository.create(draftUser)
  -> tuple[id, name]
  -> Controller performs session update / redirect
```

`signIn` is an update-side flow oriented towards authentication rather than creation:

```text
Route.post("/login")
  -> auth_controller.signIn(context)
  -> LoginUsecase.new()
  -> LoginUsecase.invoke(email, password)
  -> Email.new / Password.new
  -> repository.getUserByEmail(email)
  -> UserService.isMatchPassword(...)
  -> tuple[id, name]
  -> Controller performs session update / redirect
```

### 20.3 Responsibilities the Usecase should NOT have:

- Writing SQL directly
- Constructing HTML or Responses
- Dependence on `Context`
- Assembling read-side DTOs

### 2.5 Aggregate / Entity

Central models for the update-side are placed under aggregates. In implementation, entities are basically placed under aggregates.

### 21.1 Naming

Naming under aggregates should follow these basics:

- Aggregate roots or entities: `User`, `DraftUser`, `Follow`
- Location: `models/aggregates/<aggregate_name>/...`

Examples:

- `models/aggregates/user/user_entity.nim`
- `models/aggregates/user/user_service.nim`
- `models/aggregates/user/user_repository_interface.nim`

### 21.2 Role of Entity

Entities represent the domain state to be updated.

- `DraftUser`: User intended for new creation
- `User`: Persisted user

Separating types between pre-creation and post-creation is an effective pattern.

For example, performing `UserId.new()` or `HashedPassword.new(password)` within `DraftUser.new(...)` allows the formatting responsibility during creation to be shifted to the entity side.

### 21.3 Design Policy

- Place update-side models under aggregates.
- Repositories return aggregates/entities, not DTOs.
- If states differ before and after creation, use separate types.
- Have VOs as fields.
- Divide entities into units meaningful within the domain.

### 2.6 Domain Service

Decisions that are difficult to represent with a single aggregate, or decisions using a repository, are placed in a domain service.

### 22.1 Naming

Domain services are named `*Service`.

Examples:

- `UserService`

### 22.2 Responsibilities

The responsibilities of a domain service are as follows:

- Existence or duplication checks using a repository
- Domain decisions such as value comparisons or hash verification
- Representation of business rules that don't fit easily into aggregates

The following responsibilities are typical for `UserService`:

- `isEmailUnique(email)`
- `isExistsUser(userId)`
- `isMatchPassword(input, hashed)`

### 22.3 Design Policy

- Focus services on domain decisions.
- Leave the persistence of update results to the repository.
- Do not bring in HTTP or View concepts.

### 2.7 Value Object

After the usecase receives a string, it is converted to a VO at an early stage of the update process.

### 23.1 Naming

VOs should basically represent business meaning through their type name.

Examples:

- `UserId`
- `UserName`
- `Email`
- `Password`
- `HashedPassword`
- `Bio`
- `Image`

Placement should basically be in `models/vo/...`.

### 23.2 Role

The role of a VO is as follows:

- Convert primitive strings into types meaningful within the domain
- Concentrate invalid value checks in the constructor
- Reduce "plain strings" in subsequent layers

For example, the following responsibilities are included:

- `UserName.new(value)`: Empty strings not allowed
- `UserId.new(value)`: Empty ids not allowed
- `HashedPassword.new(password)`: Hashing

### 23.3 Design Policy

- Convert to VO as early as possible at the usecase entry point.
- Prioritize VOs over primitives for repository or service arguments.
- Concentrate validation and normalization in the VO's `new`.
- Domain errors may fail at the point of VO generation.

### 2.8 Repository Interface

The boundary for persisting and restoring aggregates is the repository.

### 24.1 Naming

Repository interfaces should basically be named `I<AggregateName>Repository`.

Examples:

- `IUserRepository`

We recommend placing it under the aggregate:

- `models/aggregates/user/user_repository_interface.nim`

### 24.2 Role

The responsibilities of a repository interface are as follows:

- Define APIs for retrieving aggregates/entities
- Define APIs for persistence such as create/update
- Separate usecases from concrete implementations

A typical interface looks like this:

```text
getUserByEmail(email: Email): Future[Option[User]]
getUserById(userId: UserId): Future[Option[User]]
create(user: DraftUser): Future[void]
update(user: User): Future[void]
```

A major difference from read-side DAOs is using `User` or `DraftUser` as return values instead of DTOs.

### 2.9 Repository Implementation

Concrete classes implementing repository interfaces are placed under `data_stores/repositories/...`.

### 25.1 Naming

- Production implementation: `<AggregateName>Repository`
- Test implementation: `Mock<AggregateName>Repository`

Examples:

- `UserRepository`
- `MockUserRepository`

### 25.2 Responsibilities

The responsibilities of a repository implementation are as follows:

- Restore aggregates/entities from database rows
- Save aggregates/entities to the database
- Mutually convert between persistence and domain formats

The typical flow is as follows:

```text
repository.getUserByEmail(email)
  -> Retrieve DB row
  -> Restore to UserId / UserName / Email / HashedPassword, etc.
  -> Restore and return User aggregate
```

```text
repository.create(draftUser)
  -> Expand draftUser's VOs into primitives
  -> insert
```

### 25.3 Responsibilities the Repository should NOT have:

- Formatting for HTML
- Dependence on request-local `Context`
- Assembling DTOs for read-side templates

### 2.10 DI Container

Repositories upon which usecases or services depend in the write-side are resolved from the `di container`.

### 26.1 Naming

Field names on the DI container should basically follow lowerCamelCase to convey the interface's meaning.

Examples:

- `userRepository*: IUserRepository`

### 26.2 Role

The responsibilities of the write-side `di container` are as follows:

- Bind repository interfaces to concrete implementations
- Switch between test and production implementations
- Prevent usecases/services from directly depending on concrete classes

In `di_container.nim`, we recommend separating write-side and read-side with comments, placing repositories in the write-side and DAOs in the read-side.

### 26.3 Principles

- Usecases depend through interfaces, such as `di.userRepository`.
- Services also depend on the same repository interface if necessary.
- Do not retrieve repositories directly from controllers.

### 2.11 Recommended Flow

The standard form for Basolato's write-side based on `signUp` is as follows:

```text
Route.post
  -> controller
  -> validation
  -> usecase
  -> Generate VOs such as UserName / Email / Password
  -> Business decisions by repository / service
  -> Generate aggregate entities such as DraftUser / User
  -> repository.create / update
  -> Controller handles session / flash / redirect
```

The code structure is as follows:

```nim
proc someAction*(context: Context): Future[Response] {.async.} =
  let validation = RequestValidation.new(context)
  # validate...

  if validation.hasErrors():
    context.storeValidationResult(validation).await
    return redirect("/form")

  let a = context.params.getStr("a")
  let b = context.params.getStr("b")

  try:
    let usecase = SomeUsecase.new()
    let result = usecase.invoke(a, b).await
    return redirect("/")
  except:
    let error = getCurrentExceptionMsg()
    context.storeError(error).await
    return redirect("/form")
```

```nim
proc invoke*(self: SomeUsecase, a, b: string) {.async.} =
  let a = SomeVo.new(a)
  let b = AnotherVo.new(b)
  let entity = SomeAggregate.new(a, b)
  self.repository.create(entity).await
```

### 2.12 Patterns to Avoid

In Basolato's POST write-side, it is desirable to avoid the following writing styles:

- Calling repositories directly from the controller
- Completing everything from VO generation to persistence in the controller
- Usecases depending on `Context`
- Repositories returning DTOs and becoming the center of the update-side
- Repurposing read-side DAOs for write-side updates
- Advancing updates using only primitives without using aggregates
- Placing domain decisions in controllers or template models

These break the boundaries of update-side responsibilities and obscure the location of business rules.

### 2.13 Summary of Design Principles

Basolato's POST write-side is designed based on the following principles:

- `Route.post` remains just as an entry point definition.
- Controllers focus on input reception, validation, and redirection.
- Usecases act as facilitators for update usecases.
- Place entities, services, and repository interfaces under aggregates.
- Convert primitives to domain types using value objects.
- Repositories handle the restoration and persistence of aggregates.
- Make repository implementations swappable through the di container.
- Do not mix read-side DAOs / DTOs with write-side repositories / aggregates.

In short, the write-side design of Basolato is based on the separation of responsibilities: `Route.post -> controller -> usecase -> value object -> aggregate/entity -> service -> repository -> di container -> redirect`.

# Presenters & ViewModels

This directory contains Presenters and ViewModels that transform HTTP/business data into view-friendly formats.

## Naming Convention

For a page accessible at route `/sample/login`:

- **ViewModel**: `login_page_viewmodel.nim` → `LoginPageViewModel` type
- **Presenter** (optional): `login_presenter.nim` → `LoginPresenter` type

## ViewModel Structure

Each page-level ViewModel file should follow this structure:

```nim
# presenters/login/login_page_viewmodel.nim
import ../../../../../../../src/basolato/view

type LoginPageViewModel* = object
  isLogin*: bool
  name*: string
  formParams*: Params
  formErrors*: seq[string]

proc new*(_: type LoginPageViewModel, isLogin: bool, name: string, formParams: Params, formErrors: seq[string]): LoginPageViewModel =
  return LoginPageViewModel(
    isLogin: isLogin,
    name: name,
    formParams: formParams,
    formErrors: formErrors
  )
```

**Rules:**
- ViewModel type: `{PageName}ViewModel` (e.g., `LoginPageViewModel`)
- Constructor: `new()` with all fields
- All fields: `export` (use `*` suffix)
- Immutable: Fields should not be modified after creation

## Presenter Structure (Optional)

Presenter is useful when transformation logic is complex or shared between multiple pages.

```nim
# presenters/login/login_presenter.nim
import ../../../../../../../src/basolato/view
import ./login_page_viewmodel

type LoginPresenter* = object

proc new*(_: type LoginPresenter): LoginPresenter =
  return LoginPresenter()

proc invoke*(self: LoginPresenter, isLogin: bool, name: string, formParams: Params, formErrors: seq[string]): LoginPageViewModel =
  return LoginPageViewModel.new(isLogin, name, formParams, formErrors)
```

**Rules:**
- One Presenter per ViewModel (or omit if transformation is trivial)
- `invoke()` method: returns ViewModel
- Stateless: Presenter instance can be reused

## Using from Page

```nim
# pages/login/login_page.nim
import ../../templates/login/login_template
import ../../presenters/login/login_page_viewmodel

proc loginPage*(): Future[Component] {.async.} =
  let context = context()
  let (params, errors) = context.getParamsWithErrorsList().await
  let isLogin = context.isLogin().await
  let name = context.session.get("name").await
  
  let vm = LoginPageViewModel.new(isLogin, name, params, errors)
  return loginTemplate(vm)
```

## Sub-Objects in ViewModel

For complex pages, break ViewModel into sub-objects:

```nim
type AuthModel* = object
  isLogin*: bool
  userName*: string
  role*: string

type FormModel* = object
  params*: Params
  errors*: seq[string]

type DashboardPageViewModel* = object
  auth*: AuthModel
  form*: FormModel
  title*: string
```

**Benefits:**
- Clearer semantics
- Easier to extend per concern
- Still single argument to Template

## Component ViewModels

For reusable components, use Component-specific ViewModels:

```nim
# components/card/card_component_model.nim
type CardComponentModel* = object
  title*: string
  content*: string
  footer*: string

# components/card/card_component.nim
proc cardComponent*(model: CardComponentModel): Component =
  # Render using model
```

**Note:** Don't create ComponentModels unless the component is truly reusable.

## Testing ViewModels

```nim
import unittest
import ../../presenters/login/login_page_viewmodel
import basolato/view

suite "LoginPageViewModel":
  test "new creates valid ViewModel":
    let vm = LoginPageViewModel.new(
      isLogin = true,
      name = "John",
      formParams = Params.new(),
      formErrors = @[]
    )
    check vm.isLogin == true
    check vm.name == "John"
    check vm.formErrors.len == 0
```

## Anti-Patterns

❌ **Don't:**
- Call `context()` from Presenter/ViewModel
- Mutate ViewModel fields after creation
- Store mutable state in ViewModel
- Pass large domain objects directly (transform first)
- Use ViewModel as DTO for API responses

✅ **Do:**
- Keep ViewModels immutable
- Transform business data into view format
- Use sub-objects to avoid parameter explosion
- Clear semantics: `AuthModel`, `FormModel`, `PaginationModel`
- Separate DTO (for API) from ViewModel (for views)

## Deprecation Note

Signal-based state sharing is deprecated. If you see imports like:

```nim
import ../../signals/login_signal
```

Migrate to this Presenter/ViewModel pattern instead.
See `signals/DEPRECATION.md` for details.

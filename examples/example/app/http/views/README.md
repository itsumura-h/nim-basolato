Views
===

All views are located inside this directory.
Views are HTML files or Nim template views.

## Architecture

Basolato follows the **Page → Presenter → ViewModel → Template** pattern for request-local, immutable view data.

```
HTTP Request
    ↓
Page (pages/*.nim)
    ↓ (extract HTTP context, prepare display data)
Presenter (presenters/*.nim)
    ↓ (convert domain/business data to view-friendly format)
ViewModel (presenters/*_viewmodel.nim)
    ↓ (immutable view model, passed to template)
Template (templates/*.nim)
    ↓ (render HTML using ViewModel)
HTTP Response
```

## Directory Structure

### pages/
Entry points for HTTP routes. Responsibilities:
- Extract request parameters and validation errors
- Get session/authentication state
- Call Presenter to build ViewModel
- Pass ViewModel to Template

**Example:**
```nim
proc loginPage*(): Future[Component] {.async.} =
  let context = context()
  let (params, errors) = context.getParamsWithErrorsList().await
  let isLogin = context.isLogin().await
  let name = context.session.get("name").await
  
  let vm = LoginPageViewModel.new(isLogin, name, params, errors)
  return loginTemplate(vm)
```

### presenters/
Convert business/domain data into view-friendly ViewModels.

**Responsibilities:**
- Transform raw HTTP/domain data into ViewModel
- Prepare display-specific fields (e.g., formatted dates, computed flags)
- Hide internal details; expose only what Template needs
- Keep ViewModel immutable and request-local

**Structure:**
- `presenters/<page_name>/<page_name>_viewmodel.nim`: ViewModel definition
- `presenters/<page_name>/<page_name>_presenter.nim`: Presenter logic (optional)

**Example:**
```nim
# presenters/login/login_page_viewmodel.nim
type LoginPageViewModel* = object
  isLogin*: bool
  name*: string
  formParams*: Params
  formErrors*: seq[string]
```

### templates/
Render HTML using the provided ViewModel. **Do not** query context or session directly.

**Responsibilities:**
- Accept ViewModel as parameter
- Render HTML based on ViewModel data
- Use view helpers (csrfToken, old, etc.) via ViewModel or imported functions
- Remain pure rendering logic with minimal business logic

**Example:**
```nim
proc loginTemplate*(vm: LoginPageViewModel): Component =
  let formParams = vm.formParams
  let formErrors = vm.formErrors
  let isLogin = vm.isLogin
  
  tmpl"""
    <form>
      $if formErrors.len > 0{
        <ul>
          $for error in formErrors{
            <li>$(error)</li>
          }
        </ul>
      }
      <input type="text" name="name" value="$(formParams.old("name"))">
      <button type="submit">Login</button>
    </form>
  """
```

### layouts/
Shared layout structure for multiple pages.

**Responsibilities:**
- Define page frame (head, body, common header/footer)
- Provide layout models for consistent structure
- Support nested layouts

### components/
Reusable UI components within pages.

**Responsibilities:**
- Encapsulate recurring UI patterns
- Accept minimal input (use ViewModel for complex data)
- Avoid stateful behavior

## Guidelines

### ViewModel Design

- **Single responsibility**: One ViewModel per page/screen
- **Immutable**: Treat ViewModels as read-only after creation
- **Minimal**: Include only data needed for rendering
- **Flat or light hierarchy**: Avoid deep nesting; use sub-objects for clarity (e.g., `auth`, `form`, `flash`)

**Anti-pattern (too many arguments):**
```nim
proc template(title: string, errors: seq[string], userName: string, isLogin: bool, ...): Component
```

**Better pattern (single ViewModel):**
```nim
type PageViewModel = object
  title*: string
  errors*: seq[string]
  auth*: AuthModel
  form*: FormModel

proc template(vm: PageViewModel): Component
```

### Data Flow

1. **Page**: HTTP entry point, orchestrate data gathering
2. **Presenter**: Transform domain data into display format
3. **ViewModel**: Immutable container for view data
4. **Template**: Pure rendering based on ViewModel

**Don't:**
- Call `context()` from Template
- Mutate ViewModel after creation
- Pass large domain objects directly to Template
- Store request data in global state (signals)

### Deprecation

Signal-based state sharing is **deprecated**. See `signals/DEPRECATION.md` for migration guide.

## layoutes
This directory is used to locate files which are component parts.

## pages
This directory is used to locate files which are page's unique content.

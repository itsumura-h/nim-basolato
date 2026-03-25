Views
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

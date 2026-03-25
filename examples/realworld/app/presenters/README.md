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

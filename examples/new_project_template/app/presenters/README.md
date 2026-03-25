Presenters
==========

This directory contains helpers that transform request or business data into view-friendly models.

## Responsibilities

- Convert `Context`, DTOs, and small domain results into page or component view models
- Keep transformation logic that would otherwise be duplicated in templates
- Return immutable `ViewModel` or `ComponentModel` values
- Stay request-local, side-effect free, and easy to test

## Usage

- Place page-specific presenters under `presenters/<page>/`
- Define `new*` or `invoke*` as the entry point
- Use presenters from pages or template-model construction code
- Keep presenters free from DB access and HTML rendering

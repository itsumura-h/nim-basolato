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

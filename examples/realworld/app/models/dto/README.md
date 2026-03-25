DTO
===

This directory contains **read-side data transfer types**.
Each DTO defines the shape of data returned by a DAO for a page, a list, or a detail view.

## Responsibilities

- Package results fetched from databases or external APIs into a UI-friendly shape
- Represent retrieval results at the page or fragment level, such as lists and detail views
- Serve as the return type of DAOs and be passed to templates and pages
- Keep the minimal transformation needed for display inside `new`
- Stay focused on read-side composition and avoid business mutation rules

## Implementation Guidelines

- Place one display unit in one DTO file
- Compose small DTOs when the view needs nested data, such as author, tag, or summary models
- Normalize DB strings and timestamps into display-friendly types inside `new`
- Define DAO interfaces around use cases, such as `findById`, `list`, or `count`
- Let list-style DAOs accept paging information such as `offset`, `limit`, or cursor values
- Keep DTO fields primitive or DTO-only so they stay easy to serialize and render

## How To Think About It

- If the data is only needed to render a page or fragment, it likely belongs here
- If the data is a business concept that can be changed, it likely belongs in aggregates or value objects
- If the data combines multiple tables for display, the DAO should build the DTO here

## Do Not Put Here

- Aggregate update logic
- Repositories
- Domain rule validation
- DB write operations
- `Context`-dependent access

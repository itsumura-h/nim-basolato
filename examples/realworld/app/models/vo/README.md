Value Objects
===

This directory contains **values with domain meaning**.
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
- request-local data

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

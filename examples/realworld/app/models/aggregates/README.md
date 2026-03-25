Aggregates
===

This directory contains the **write-side domain models**.
Each aggregate represents one business boundary and owns the rules that must stay consistent inside that boundary.

## Responsibilities

- Represent business-meaningful state for one domain boundary
- Enforce invariants, validation, and state transitions close to the model
- Keep construction logic such as IDs, timestamps, and defaults inside `new`
- Separate persisted state from input-ready state when that improves clarity
- Define the persistence boundary through repository interfaces
- Move rules that do not belong inside the aggregate to a `service`

## Implementation Guidelines

- Use `vo` types for business values
- Collect all values needed for creation into a dedicated input or draft type when the constructor would otherwise become too large
- Initialize values such as `now().utc()`, UUIDs, and hashes inside `new`
- Put the entity type in `*_entity.nim`
- Put create/read/update contracts in `*_repository_interface.nim`
- Put cross-aggregate rules in `*_service.nim` when needed
- Keep file names aligned with the aggregate name

## How To Think About It

- If a rule changes the meaning or validity of the aggregate, keep it here
- If a rule coordinates multiple aggregates, move it to a service
- If a value should never be represented as a raw primitive in this domain, model it as a `vo`

## Do Not Put Here

- SQL
- DAO
- view-oriented data
- request-local `Context`
- JSON assembly

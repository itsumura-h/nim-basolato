Controllers
===
Controllers receive requests and choose the response to return.

## Naming

- `GET` handlers that render HTML should be named `XxxPage`.
- Those handlers should call `XxxPageView` in `http/views/pages`.
- Action-style handlers for `POST`, `PUT`, `DELETE`, and similar routes may keep verb-oriented names.

## Duties

- Receive request and URL parameters
- Perform validation checks
- Create model instances or call usecases
- Catch and handle exceptions
- Select the response object
- Return response data

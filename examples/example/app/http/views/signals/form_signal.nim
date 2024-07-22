import std/json
import ../../../../../../src/basolato/view

let formErrorsSignal* = createSignal(newSeq[string]())
let formParamsSignal* = createSignal(newJNull())

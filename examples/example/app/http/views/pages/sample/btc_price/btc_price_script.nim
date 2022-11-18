import std/asyncjs
import std/dom
import std/jsconsole
import std/jscore
import std/jsffi

var Alpine {.importc.}: JsObject

type IntInternal = ref object
  val:int

type IntState = ref object
  alpineState:JsObject

proc get(self:IntState):int = self.alpineState.val.to(int)
proc update(self:IntState, val:int) = self.alpineState.val = val
proc useState(val:int):IntState = IntState(alpineState: Alpine.reactive(IntInternal(val:val)))


type FloatInternal = ref object
  val:float

type FloatState = ref object
  alpineState:JsObject

proc get(self:FloatState):float = self.alpineState.val.to(float)
proc update(self:FloatState, val:float) = self.alpineState.val = val
proc useState(val:float):FloatState = FloatState(alpineState: Alpine.reactive(FloatInternal(val:val)))


type BoolInternal = ref object
  val:bool

type BoolState = ref object
  alpineState:JsObject

proc get(self:BoolState):bool = self.alpineState.val.to(bool)
proc update(self:BoolState, val:bool) = self.alpineState.val = val
proc useState(val:bool):BoolState = BoolState(alpineState: Alpine.reactive(BoolInternal(val:val)))


type StringInternal = ref object
  val:string

type StringState = ref object
  alpineState:JsObject

proc get(self:StringState):string = self.alpineState.val.to(string)
proc update(self:StringState, val:string) = self.alpineState.val = val
proc useState(val:string):StringState = StringState(alpineState: Alpine.reactive(StringInternal(val:val)))


proc useEffect(cb:proc()) =
  Alpine.effect(cb.toJs())


# ==================================================
var data:IntState

proc mount(id:cstring) {.exportc.} = 
  let dom = document.getElementById(id)
  console.log(dom)
  
  data = useState(1)
  console.log(data)

  useEffect(
    proc() =
      console.log("=== effect")
      console.log(data.get)
  )

proc incrementNum() {.exportc.} =
  data.update(data.get + 1)


# ==================================================

# var data:JsObject

# type State = ref object
#     val:int

# proc mount(id:cstring) {.exportc.} =
#   let dom = document.getElementById(id)
#   console.log(dom)

#   console.log(Alpine)
#   data = Alpine.reactive(State(val:1))

#   Alpine.effect((
#     proc() =
#       console.log("=== effect")
#       console.log(data.val)
#     ).toJs()
#   )

# proc incrementNum() {.exportc.} =
#   data.val = data.val.to(int) + 1

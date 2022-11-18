class IntInternal{
  val

  constructor(val){
    this.val = val
  }

  update(val){
    this.val = val
  }
}

class IntState{
  alpineState

  constructor(alpineState){
    this.alpineState = alpineState
  }

  getInt(){
    return this.alpineState.val
  }

  update(val){
    this.alpineState.update(val)
  }
}

const useState=(val)=>{
  return new IntState(Alpine.reactive(new IntInternal(val)))
  // const data = Alpine.reactive({val:val});
}

const useEffect=(func)=>{
  Alpine.effect(func)
}


// ==================================================

// let data;

// const mount = (id) => {
//   const dom = document.getElementById(id);
//   console.log(dom)

//   data = Alpine.reactive({ val: 1 });
//   Alpine.effect(() => {
//     console.log("=== effect");
//     console.log(data.val);
//   });
// };

// const incrementNum = () => {
//   data.val = data.val + 1;
// };


// ==================================================
let data;

const mount=(id)=>{
  let dom = document.getElementById(id)
  console.log(dom)

  data = useState(1)
  console.log(data)

  useEffect(()=>{
    console.log("=== effect")
    console.log(data.getInt())
  })
}

const incrementNum=()=>{
  data.update(data.getInt() + 1)
}

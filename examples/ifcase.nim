import times, strformat

type A = ref object
  num:int

proc check(i:int): string =
  if i mod 15 == 0:
    return "FizzBuzz"
  elif i mod 3 == 0:
    return "fizz"
  elif i mod 5 == 0:
    return "buzz"
  else:
    return $i

let if_start_time = getTime()
for i in 0..2000:
  let a = A(num:i)

  let r = check(a.num)
  if r == "FizzBuzz":
    echo "FizzBuzz"
  elif r == "fizz":
    echo "fizz":
  elif r == "buzz":
    echo "buzz":
  else:
    echo r

let if_end_time = getTime() - if_start_time # Duration型
let if_result_time = &"{if_end_time.inSeconds}.{if_end_time.inMicroseconds}"


let case_start_time = getTime()
for i in 0..2000:
  let b = A(num:i)

  let r = check(b.num)
  case r:
  of "FizzBuzz":
    echo "FizzBuzz"
  of "fizz":
    echo "fizz"
  of "buzz":
    echo "buzz"
  else:
    echo r


let case_end_time = getTime() - case_start_time # Duration型
let case_result_time = &"{case_end_time.inSeconds}.{case_end_time.inMicroseconds}"

echo if_result_time
echo case_result_time
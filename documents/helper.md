Healper
===
[back](../README.md)

Table of Contents

<!--ts-->
   * [Healper](#healper)
      * [dd](#dd)

<!-- Added by: root, at: Fri Jul 31 13:19:37 UTC 2020 -->

<!--te-->

## dd
```
proc dd(outputs:varges[string])
```
`dd()` is essentially adding a break point in your code which dumps the properties of an object to your browser.  
This proc is only available in develop mode.

```nim
var a = %*{
  "key1": "value1",
  "key2": "value2",
  "key3": "value3",
  "key4": "value4",
}
dd($a,　"abc",　this.request.repr)
```

![dd](helper-dd.jpg)

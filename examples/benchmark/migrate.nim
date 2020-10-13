import random, json
import allographer/schema_builder
import allographer/query_builder

randomize()

schema(
  table("world", [
    Column().increments("id"),
    Column().integer("randomNumber").default(0)
  ], reset=true),
  table("fortune", [
    Column().increments("id"),
    Column().string("message")
  ], reset=true)
)

echo rdb().table("world").get()

var data = newSeq[JsonNode]()
for i in 1..10000:
  data.add(
    %*{"randomNumber": rand(1..10000)}
  )
rdb().table("world").insert(data)

data = @[
  %*{"id": 1, "message": "fortune: No such file or directory"},
  %*{"id": 2, "message": "A computer scientist is someone who fixes things that aren''t broken."},
  %*{"id": 3, "message": "After enough decimal places, nobody gives a damn."},
  %*{"id": 4, "message": "A bad random number generator: 1, 1, 1, 1, 1, 4.33e+67, 1, 1, 1"},
  %*{"id": 5, "message": "A computer program does what you tell it to do, not what you want it to do."},
  %*{"id": 6, "message": "Emacs is a nice operating system, but I prefer UNIX. — Tom Christaensen"},
  %*{"id": 7, "message": "Any program that runs right is obsolete."},
  %*{"id": 8, "message": "A list is only as strong as its weakest link. — Donald Knuth"},
  %*{"id": 9, "message": "Feature: A bug with seniority."},
  %*{"id": 10, "message": "Computers make very fast, very accurate mistakes."},
  %*{"id": 11, "message": """<script>alert("This should not be displayed in a browser alert box.");</script>"""},
  %*{"id": 12, "message": "フレームワークのベンチマーク"},
]

rdb().table("fortune").insert(data)

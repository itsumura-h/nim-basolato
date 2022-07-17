nim c \
  -d:ssl \
  --threads:on \
  --threadAnalysis:off \
  --gc:orc \
  --putenv:PORT=3000 \
  --excessiveStackTrace:off \
  -d:release \
  --passC:-flto \
  --passL:-flto \
server.nim

./server

import json, asyncdispatch
import allographer/schema_builder
import allographer/query_builder
from ../databases import rdb

proc migration20210811183719world*() =
  const sql = """
CREATE TABLE  "World" (
  id integer NOT NULL,
  randomNumber integer NOT NULL default 0,
  PRIMARY KEY  (id)
);
GRANT ALL PRIVILEGES ON "World" to benchmarkdbuser;
INSERT INTO "World" (id, randomnumber)
SELECT x.id, least(floor(random() * 10000 + 1), 10000) FROM generate_series(1,10000) as x(id);
"""
  waitFor rdb.raw(sql).exec()

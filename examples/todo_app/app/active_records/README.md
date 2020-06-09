Active record
===
The duty of active record is
- To hide sql query and run

Difinition
```nim
type User = ref object of ActiveRecord

proc newUser*():RDB =
  return User.newActiveRecord()
```

Usage
```nim
let users = newUser().select("id", "name").where("id", ">", 5).limit(10).get()
```

`newActiveRecord()` define table name automatically by making type name lower case and add `s`  
User => users  
Book => books  
If table name is a noun which change irregularly, define plural form.

```nim
type Goose = ref object of ActiveRecord

proc newGoose*():RDB =
  return Goose.newActiveRecord(table="geese")
```
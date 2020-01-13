import os

# DB Connection
putEnv("db.driver", "sqlite")
putEnv("db.connection", "/home/www/example/db.sqlite3")
putEnv("db.user", "")
putEnv("db.password", "")
putEnv("db.database", "")

# Logging
putEnv("log.isDisplay", "true")
putEnv("log.isFile", "true")
putEnv("log.dir", "/home/www/example/logs")

# Session timeout
putEnv("session.time", $(60*60*1)) # secound*minutes*day

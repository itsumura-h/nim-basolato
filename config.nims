import os

# DB Connection
putEnv("db.driver", "sqlite")
putEnv("db.connection", "/home/www/db.sqlite3")
putEnv("db.user", "")
putEnv("db.password", "")
putEnv("db.database", "")

# Logging
putEnv("log.isDisplay", "true")
putEnv("log.isFile", "true")
putEnv("log.dir", "/home/www/logs")

import os

# DB Connection
putEnv("DB_DRIVER", "sqlite")
putEnv("DB_CONNECTION", "/root/project/example/db.sqlite3")
#putEnv("DB_DRIVER", "mysql")
#putEnv("DB_CONNECTION", "mysql:3306")
# putEnv("DB_DRIVER", "postgres")
# putEnv("DB_CONNECTION", "postgres:5432")
putEnv("DB_USER", "user")
putEnv("DB_PASSWORD", "Password!")
putEnv("DB_DATABASE", "allographer")

# Logging
putEnv("LOG_IS_DISPLAY", "true")
putEnv("LOG_IS_FILE", "true")
putEnv("LOG_DIR", "/root/project/example/logs")

# Security
putEnv("SECRET_KEY", "s40q834uc0mq4ur834u3874u843r734r")
putEnv("CSRF_TIME", "525600") # minutes 1 year
putEnv("SESSION_TIME", "20160") # minutes 2 weeks
putEnv("SESSION_DB_PATH", "/root/project/example/session.db")
putEnv("IS_SESSION_MEMORY", "false")

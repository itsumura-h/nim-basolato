import os
# DB Connection
putEnv("DB_DRIVER", "postgres")
# Session db
putEnv("SESSION_TYPE", "file") # "file" or "redis"

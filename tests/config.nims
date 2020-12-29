import os

# Security
putEnv("SECRET_KEY", "h6G?>V3_K}_x^&R*L4^2luH$") # 24 length

# DB Connection
putEnv("DB_DRIVER", "sqlite")
putEnv("DB_CONNECTION", "/root/project/tests/server/db.sqlite3")
putEnv("DB_USER", "")
putEnv("DB_PASSWORD", "")
putEnv("DB_DATABASE", "")
putEnv("DB_MAX_CONNECTION", "95")

# Logging
putEnv("LOG_IS_DISPLAY", "true")
putEnv("LOG_IS_FILE", "true")
putEnv("LOG_IS_ERROR_FILE", "true")
putEnv("LOG_DIR", "/root/project/tests/server/logs")

putEnv("SESSION_TYPE", "file") # file or redis
putEnv("SESSION_TIME", "20160") # minutes of 2 weeks
putEnv("SESSION_DB_PATH", "/root/project/tests/server/session.db")
putEnv("REDIS_PORT", "6379")
putEnv("COOKIE_DOMAINS", "")

putEnv("port", "5000")

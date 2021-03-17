import os

# Security
putEnv("SECRET_KEY", "QPyp/t^KTtw;xrN/Hzl&/AIr") # 24 length

# DB Connection
putEnv("DB_DRIVER", "sqlite")
putEnv("DB_CONNECTION", "/root/project/examples/example/db.sqlite3")
putEnv("DB_USER", "")
putEnv("DB_PASSWORD", "")
putEnv("DB_DATABASE", "")
putEnv("DB_MAX_CONNECTION", "95")

# Logging
putEnv("LOG_IS_DISPLAY", "true")
putEnv("LOG_IS_FILE", "true")
putEnv("LOG_IS_ERROR_FILE", "true")
putEnv("LOG_DIR", "/root/project/examples/example/logs")

# Session db
putEnv("SESSION_TYPE", "file") # file or redis
putEnv("SESSION_DB_PATH", "/root/project/examples/example/session.db")
# putEnv("SESSION_DB_PATH", "redis")
putEnv("SESSION_TIME", "20160") # minutes of 2 weeks
putEnv("REDIS_PORT", "6379")
putEnv("ENABLE_ANONYMOUS_COOKIE", "false")
putEnv("COOKIE_DOMAINS", "localhost, amazon.com, google.com")

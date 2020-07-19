import os

# DB Connection
putEnv("DB_DRIVER", "postgres")
putEnv("DB_CONNECTION", "localhost:5432")
putEnv("DB_USER", "benchmarkdbuser")
putEnv("DB_PASSWORD", "benchmarkdbpass")
putEnv("DB_DATABASE", "hello_world")

# Logging
putEnv("LOG_IS_DISPLAY", "true")
putEnv("LOG_IS_FILE", "true")
putEnv("LOG_DIR", "/root/project/examples/basolato/logs")

# Security
putEnv("SECRET_KEY", "PuolviY&~b]i4Tu?).j;p$DL") # 24 length
putEnv("CSRF_TIME", "525600") # minutes of 1 year
putEnv("SESSION_TIME", "20160") # minutes of 2 weeks
putEnv("SESSION_DB", "/root/project/examples/basolato/session.db")
putEnv("IS_SESSION_MEMORY", "false")

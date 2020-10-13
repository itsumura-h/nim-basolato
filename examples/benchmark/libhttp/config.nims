import os

# DB Connection
putEnv("DB_DRIVER", "postgres")
putEnv("DB_CONNECTION", "postgres:5432")
putEnv("DB_USER", "user")
putEnv("DB_PASSWORD", "Password!")
putEnv("DB_DATABASE", "allographer")

# Logging
putEnv("LOG_IS_DISPLAY", "false")
putEnv("LOG_IS_FILE", "false")
putEnv("LOG_DIR", "/root/project/examples/benchmark/basolato/logs")

# Security
putEnv("SECRET_KEY", "<bA^V0&&4-%F=YN|AZXCZZ}0") # 24 length
putEnv("CSRF_TIME", "525600") # minutes of 1 year
putEnv("SESSION_TIME", "20160") # minutes of 2 weeks
putEnv("SESSION_DB", "/root/project/examples/benchmark/basolato/session.db")
putEnv("IS_SESSION_MEMORY", "false")

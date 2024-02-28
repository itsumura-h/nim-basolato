import os

# DB Connection
putEnv("DB_POSTGRES", $true)
putEnv("DB_DATABASE", "database")
# putEnv("DB_DRIVER", "mysql")
# putEnv("DB_CONNECTION", "tfb-database-my:3306")
putEnv("DB_USER", "user")
putEnv("DB_PASSWORD", "pass")
putEnv("DB_MAX_CONNECTION", "95")
# Logging
putEnv("LOG_IS_DISPLAY", "false")
putEnv("LOG_IS_FILE", "false")
putEnv("LOG_DIR", "/root/project/examples/benchmark/asynchttpserver/logs")

# Security
putEnv("SECRET_KEY", "<bA^V0&&4-%F=YN|AZXCZZ}0") # 24 length
putEnv("CSRF_TIME", "525600") # minutes of 1 year
putEnv("SESSION_TIME", "20160") # minutes of 2 hours
putEnv("SESSION_DB_PATH", "/root/project/examples/benchmark/basolato/session.db")
putEnv("IS_SESSION_MEMORY", "false")

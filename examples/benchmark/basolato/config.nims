import os

# Security
putEnv("SECRET_KEY", "rHp(F[&&O>geIRvX!Q;lD=OB") # 24 length

# DB Connection
putEnv("DB_DRIVER", "postgres")
putEnv("DB_CONNECTION", "tfb-database-pg:5432")
putEnv("DB_USER", "benchmarkdbuser")
putEnv("DB_PASSWORD", "benchmarkdbpass")
putEnv("DB_DATABASE", "hello_world")
putEnv("DB_MAX_CONNECTION", "95")
# Logging
putEnv("LOG_IS_DISPLAY", "false")
putEnv("LOG_IS_FILE", "false")
putEnv("LOG_DIR", "/root/project/examples/benchmark/asynchttpserver/logs")

# Security
putEnv("SECRET_KEY", "<bA^V0&&4-%F=YN|AZXCZZ}0") # 24 length
putEnv("CSRF_TIME", "525600") # minutes of 1 year
putEnv("SESSION_TIME", "20160") # minutes of 2 weeks
putEnv("SESSION_DB", "/root/project/examples/benchmark/basolato/session.db")
putEnv("IS_SESSION_MEMORY", "false")


# Session db
putEnv("SESSION_TYPE", "file") # "file" or "redis"
putEnv("SESSION_DB", "/root/project/examples/benchmark/basolato/session.db")
putEnv("SESSION_TIME", "20160") # minutes of 2 weeks
putEnv("REDIS_PORT", "6379")
putEnv("ENABLE_ANONYMOUS_COOKIE", "true")
putEnv("COOKIE_DOMAINS", "")

import os
putEnv("DB_SQLITE", $true) # "true" or "false"
putEnv("DB_POSTGRES", $true) # "true" or "false"
# putEnv("DB_MYSQL", $true) # "true" or "false"
# putEnv("DB_MARIADB", $true) # "true" or "false"
putEnv("SESSION_TYPE", "file") # "file" or "redis"
# putEnv("SESSION_TYPE", "redis") # "file" or "redis"
putEnv("SESSION_DB_PATH", "./session.db") # Session file path or redis host:port. ex:"127.0.0.1:6379"
# putEnv("SESSION_DB_PATH", "redis:6379") # Session file path or redis host:port. ex:"127.0.0.1:6379"
putEnv("USE_LIBSASS", $true) # "true" or "false"

# switch("define","httpbeast")
# switch("define","httpx")

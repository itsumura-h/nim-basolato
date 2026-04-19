import os
putEnv("DB_SQLITE", $true) # "true" or "false"
putEnv("DB_POSTGRES", $true) # "true" or "false"
# putEnv("DB_MYSQL", $true) # "true" or "false"
# putEnv("DB_MARIADB", $true) # "true" or "false"
# putEnv("DB_SURREAL", $true) # "true" or "false"
putEnv("SESSION_TYPE", "file") # "file" or "redis"
# putEnv("SESSION_TYPE", "redis") # "file" or "redis"
putEnv("SESSION_PATH", "./session.db") # Session file path when SESSION_TYPE=file, or host:port when SESSION_TYPE=redis
# putEnv("SESSION_PATH", "redis:6379") # Session file path when SESSION_TYPE=file, or host:port when SESSION_TYPE=redis
putEnv("USE_LIBSASS", $true) # "true" or "false"

# switch("define","httpbeast")
# switch("define","httpx")

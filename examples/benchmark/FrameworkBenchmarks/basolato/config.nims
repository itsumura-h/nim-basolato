import std/os
putEnv("HOST", "0.0.0.0")
putEnv("DB_POSTGRES", $true) # "true" or "false"
putEnv("SESSION_TYPE", "file") # "file" or "redis"
putEnv("SESSION_PATH", "./session.db") # Session file path when SESSION_TYPE=file, or host:port when SESSION_TYPE=redis
putEnv("USE_LIBSASS", $false) # "true" or "false"

# basolato を相対パスで解決
switch("path", "../../../../src")

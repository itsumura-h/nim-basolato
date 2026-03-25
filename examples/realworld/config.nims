import std/os
putEnv("DB_SQLITE", $true) # "true" or "false"
putEnv("DB_POSTGRES", $true) # "true" or "false"
# putEnv("DB_MYSQL", $true) # "true" or "false"
# putEnv("DB_MARIADB", $true) # "true" or "false"
putEnv("SESSION_TYPE", "file") # "file" or "redis"
putEnv("LIBSASS", $false) # "true" or "false"

switch("threads", "off")

# basolato を /application/src から相対パスで解決（config のある realworld から ../../src）
switch("path", "../../src")

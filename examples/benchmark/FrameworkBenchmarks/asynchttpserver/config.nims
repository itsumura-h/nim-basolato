import os
putEnv("DB_POSTGRES", $true)

# Security
putEnv("SECRET_KEY", "<bA^V0&&4-%F=YN|AZXCZZ}0") # 24 length
putEnv("CSRF_TIME", "525600") # minutes of 1 year
putEnv("SESSION_TIME", "20160") # minutes of 2 hours
putEnv("SESSION_PATH", "/root/project/examples/benchmark/basolato/session.db") # Session file path when SESSION_TYPE=file, or host:port when SESSION_TYPE=redis
putEnv("IS_SESSION_MEMORY", "false")

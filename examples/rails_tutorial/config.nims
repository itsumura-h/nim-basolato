import os

# DB Connection
putEnv("DB_DRIVER", "sqlite")
putEnv("DB_CONNECTION", "/root/project/examples/rails_tutorial/db.sqlite3")
putEnv("DB_USER", "")
putEnv("DB_PASSWORD", "")
putEnv("DB_DATABASE", "")

# Logging
putEnv("LOG_IS_DISPLAY", "true")
putEnv("LOG_IS_FILE", "true")
putEnv("LOG_DIR", "/root/project/examples/rails_tutorial/logs")

# Security
putEnv("SALT", "$2a$10$q8ILs.SWi8QiiE31ZmWKhu") # bcrypt salt
putEnv("SECRET_KEY", "nG}@Kj%]T7<*{F!5%PS?$]Pu") # 24 length
putEnv("CSRF_TIME", "525600") # minutes of 1 year
# putEnv("SESSION_TIME", "20160") # minutes of 2 weeks
# putEnv("SESSION_TIME", "10512000") # minutes of 20 years
putEnv("SESSION_TIME", "")
putEnv("SESSION_DB", "/root/project/examples/rails_tutorial/session.db")
putEnv("IS_SESSION_MEMORY", "false")

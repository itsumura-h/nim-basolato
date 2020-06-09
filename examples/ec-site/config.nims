import os

# DB Connection
putEnv("DB_DRIVER", "sqlite")
putEnv("DB_CONNECTION", "/root/project/examples/ec-site/db.sqlite3")
putEnv("DB_USER", "")
putEnv("DB_PASSWORD", "")
putEnv("DB_DATABASE", "")

# Logging
putEnv("LOG_IS_DISPLAY", "true")
putEnv("LOG_IS_FILE", "true")
putEnv("LOG_DIR", "/root/project/examples/ec-site/logs")

# Security
putEnv("SALT", "$2a$10$zRSJRi8wTrD7GkGmov.NWO") # bcrypt salt
putEnv("SECRET_KEY", "RekpYgUSZS76+;cqZ(z^<g3O") # 24 length
putEnv("CSRF_TIME", "525600") # minutes of 1 year
putEnv("SESSION_TIME", "20160") # minutes of 2 weeks
putEnv("SESSION_DB", "/root/project/examples/ec-site/session.db")
putEnv("IS_SESSION_MEMORY", "false")

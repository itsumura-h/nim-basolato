import os
# DB Connection
putEnv("DB_DRIVER", "postgres")
putEnv("DB_CONNECTION", "tfb-database-pg:5432")
putEnv("DB_USER", "benchmarkdbuser")
putEnv("DB_PASSWORD", "benchmarkdbpass")
putEnv("DB_DATABASE", "hello_world")
putEnv("DB_MAX_CONNECTION", "95")

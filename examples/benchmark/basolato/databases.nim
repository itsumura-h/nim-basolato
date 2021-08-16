import os, strutils
import allographer/connection

echo "=== DB_MAX_CONNECTION"
echo getEnv("DB_MAX_CONNECTION")

let rdb* = dbopen(
  PostgreSQL,
  getEnv("DB_DATABASE"),
  getEnv("DB_USER"),
  getEnv("DB_PASSWORD"),
  getEnv("DB_HOST"),
  getEnv("DB_PORT").parseInt,
  getEnv("DB_MAX_CONNECTION").parseInt,
  getEnv("DB_TIMEOUT").parseInt
)

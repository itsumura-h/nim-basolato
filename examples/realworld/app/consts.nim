import std/os

const
  APP_ENV* = getEnv("APP_ENV", "develop")
  FEED_DISPLAY_COUNT* = 10

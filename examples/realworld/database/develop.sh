nim c -r -d:reset --threads:off ./database/migrations/default/migrate.nim
nim c -r --threads:off ./database/seeders/seed.nim

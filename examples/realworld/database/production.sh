# This file is executed from the root directory of the project.
nim c -r ./database/migrations/default/migrate.nim
nim c -r ./database/seeders/production.nim

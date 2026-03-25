# This file is executed from the root directory of the project.
nim c -d:reset --threads:off ./database/migrations/migrate.nim
nim c --threads:off ./database/seeders/develop

./database/migrations/migrate
./database/seeders/develop

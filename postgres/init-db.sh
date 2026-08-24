#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
    CREATE DATABASE app1_db;
    CREATE DATABASE app2_db;
    CREATE DATABASE nextcloud_db;
EOSQL

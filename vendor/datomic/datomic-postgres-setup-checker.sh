#!/usr/bin/env bash

if [ -z "${SCRIPTS_HOME}" ]
then
    SCRIPTS_HOME=/app/scripts
fi

SQL_TRANSCRIPT=/tmp/sql-output.$$

echo "Checking if postgres table exists yet.."
psql ${DATABASE_URL} < ${SCRIPTS_HOME}/datomic-table-exists-query.sql > ${SQL_TRANSCRIPT}

TABLE_EXISTS=$(grep '(1 row)' ${SQL_TRANSCRIPT})

if [ -z "${TABLE_EXISTS}" ]
then
    echo "Postgres table exists, skipping creation"
    exit 0 # All good
fi
echo "Postgres table does not exist, will be created"

if [ -z "${JDBC_DATABASE_USERNAME}" ]
then
    echo "JDBC_DATABASE_USERNAME is not known - stopping"
    exit 1
fi

INPUT=${SCRIPTS_HOME}/datomic-postgres-setup.sql
TABLE_SETUP=${INPUT}.${JDBC_DATABASE_USERNAME}

# On Heroku the user is already established in the database

sed "s/|owner|/${JDBC_DATABASE_USERNAME}/" ${INPUT} > ${TABLE_SETUP}

psql ${DATABASE_URL} < ${TABLE_SETUP} > ${SQL_TRANSCRIPT}

TABLE_CREATED=$(grep ALTER ${SQL_TRANSCRIPT})

if [ -z "${TABLE_CREATED}" ]
then
    echo "Could not create the Datomic table. SQL transcript follows:"
    cat ${SQL_TRANSCRIPT}
    exit 1
fi
echo "Postgres table created successfully"

exit 0


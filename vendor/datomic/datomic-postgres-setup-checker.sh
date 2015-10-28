#!/usr/bin/env bash

echo -n "-----> Checking Datomic <-> Postgres setup ... "

if [ -z "${SCRIPTS_HOME}" ]
then
    SCRIPTS_HOME=/app/scripts
fi

TABLE_EXISTS=`psql ${DATABASE_URL} < ${SCRIPTS_HOME}/datomic-table-exists-query.sql | grep '(1 row)'`

if [ -n "${TABLE_EXISTS}" ]
then
    echo "done"
else

    [ -z "${JDBC_DATABASE_USERNAME}" ] && echo "JDBC_DATABASE_USERNAME is not known - stopping" && exit 1

    INPUT=${SCRIPTS_HOME}/postgres-setup.sql
    TABLE_SETUP=${INPUT}.${JDBC_DATABASE_USERNAME}

    sed "s/|owner|/$JDBC_DATABASE_USERNAME/" ${INPUT} > ${TABLE_SETUP}

    TABLE_CREATED=`psql ${DATABASE_URL} < ${TABLE_SETUP} | grep ALTER`

    if [ -n "${TABLE_CREATED}" ]
    then
        echo "done"
    else
        echo "*fail*"
        exit 1
    fi

fi

exit 0

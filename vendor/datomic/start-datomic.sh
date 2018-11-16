#!/usr/bin/env bash

if [ -z "${SCRIPTS_HOME}" ]
then
    SCRIPTS_HOME=/app/scripts
fi

if [ -z "${DATOMIC_JAVA_XMX}" ]
then
    DATOMIC_JAVA_XMX=2g
fi
echo "Java max heap size set to '${DATOMIC_JAVA_XMX}'"

if [ -z "${DATOMIC_JAVA_XMS}" ]
then
    DATOMIC_JAVA_XMS=256m
fi
echo "Java min heap size set to '${DATOMIC_JAVA_XMS}'"

STORAGE_TYPE=${DATOMIC_STORAGE_TYPE:-"HEROKU_POSTGRES"}

case ${STORAGE_TYPE} in

    DYNAMODB)
        # TODO run a check against DynamoDB
        echo "Skipping check for proper dynamodb setup (not implemented)"
        ;;

    HEROKU_POSTGRES|POSTGRES)
        echo "Establishing whether Postgres is properly setup..."
        ${SCRIPTS_HOME}/datomic-postgres-setup-checker.sh
        if [ $? -ne 0 ]
        then
            echo "Failed to establish whether Postgres is properly setup - aborting dyno"
            exit 1
        fi
        ;;

    *)  echo "Unsupported storage type '${STORAGE_TYPE}'" && return 1
        ;;
esac

PROPERTIES=${SCRIPTS_HOME}/transactor.properties

DYNO_PROPERTIES=${PROPERTIES}.heroku

# Discover the IP that this dyno exposes in the Space

DYNO_IP=$(ip -4 -o addr show dev eth0 | awk '{print $4}' | cut -d/ -f1)

sed "s/^host=localhost/host=${DYNO_IP}/" ${PROPERTIES} > ${DYNO_PROPERTIES}

unset JAVA_OPTS

# Ensure Datomic does not log passwords

transactor -Ddatomic.printConnectionInfo=true -Xmx${DATOMIC_JAVA_XMX} -Xms${DATOMIC_JAVA_XMS} ${DYNO_PROPERTIES}

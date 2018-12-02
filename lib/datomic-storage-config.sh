#!/usr/bin/env bash

# This script must be source into scripts which have the following ENV vars properly set
# BUILD_DIR SCRIPTS_TARGET_DIR DATOMIC_TRANSACTOR_KEY

OUTPUT_PROPERTIES_FILE=${SCRIPTS_TARGET_DIR}/transactor.properties

SAMPLE_PROPERTIES_FILE=${BUILD_DIR}/datomic/config/samples/dev-transactor-template.properties

configure_storage() {

    echo -n "-----> Configuring Datomic to connect to DEV... "

    SAMPLE_PROPERTIES_FILE=${BUILD_DIR}/datomic/config/samples/dev-transactor-template.properties

    cat ${SAMPLE_PROPERTIES_FILE} | configure_properties > ${OUTPUT_PROPERTIES_FILE}

    echo "done"
}

configure_properties() {
    sed -e "s|^pid-file=.*|pid-file=transactor.pid|"                                  \
        -e "s|^storage-admin-password=.*|storage-admin-password=admin|"         \
        -e "s|^storage-datomic-password=.*|storage-datomic-password=client|" \
        -e "s|^storage-access=.*|storage-access=remote|" \
        -e "s|^h2-port=.*|h2-port=4335|" \
        -e "s|^license-key=.*|license-key=${DATOMIC_TRANSACTOR_KEY}|"
}

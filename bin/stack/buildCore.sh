#!/usr/bin/env bash
#
# Builds a core Stroom stack using the default configuration from the yaml.

set -e

main() {
    local -r VERSION=$1
    local -r BUILD_STACK_NAME="stroom_core"
    local -r SERVICES="stroom stroomProxyLocal stroomAllDbs stroomAuthService stroomAuthUi stroomLogSender nginx"

    ./build.sh ${BUILD_STACK_NAME} ${VERSION:-SNAPSHOT} ${SERVICES}
}

main "$@"

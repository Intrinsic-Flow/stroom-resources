#!/usr/bin/env bash
#
# shellcheck disable=SC2034
# shellcheck disable=SC1090
#
# Starts the stack, using the configuration defined in the .env file.

# We shouldn't use a lib function (e.g. in shell_utils.sh) because it will
# give the directory relative to the lib script, not this script.
readonly DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR"/lib/network_utils.sh
source "$DIR"/lib/shell_utils.sh
source "$DIR"/lib/stroom_utils.sh

# This is needed in the docker compose yaml
readonly HOST_IP=$(determine_host_address)

setup_echo_colours

# Read the file containing all the env var exports to make them
# available to docker-compose
source "$DIR"/config/<STACK_NAME>.env

check_installed_binaries() {
    # The version numbers mentioned here are mostly governed by the docker compose syntax version that 
    # we use in the yml files, currently 2.4, see https://docs.docker.com/compose/compose-file/compose-versioning/

    if ! command -v docker 1>/dev/null; then 
        echo -e "${RED}ERROR${NC}: Docker CE is not installed!"
        echo -e "See ${BLUE}https://docs.docker.com/install/#supported-platforms${NC} for details on how to install it"
        echo -e "Version ${BLUE}17.12.0${NC} or higher is required"
        exit 1
    fi

    if ! command -v docker-compose 1>/dev/null; then 
        echo -e "${RED}ERROR${NC}: Docker Compose is not installed!"
        echo -e "See ${BLUE}https://docs.docker.com/compose/install/${NC} for details on how to install it"
        echo -e "Version ${BLUE}1.23.1${NC} or higher is required"
        exit 1
    fi
}

main() {
    check_installed_binaries

    start_stack "<STACK_NAME>" "$@"

    # If any args are supplied then it means specific services are being started so we
    # can't wait for check for health as we don't know what has been started
    if [ "$#" -eq 0 ]; then

        echo
        echo -e "${GREEN}Waiting for stroom to complete its start up.${NC}"
        echo -e "${DGREY}Stroom has to build its database tables when started for the first time,${NC}"
        echo -e "${DGREY}so this may take a minute or so. Subsequent starts will be quicker.${NC}"

        wait_for_200_response "http://localhost:${STROOM_ADMIN_PORT}/stroomAdmin"

        # Stroom is now up or we have given up waiting so check the health
        check_overall_health

        # Display the banner, URLs and login details
        display_stack_info
    fi
}

main "$@"

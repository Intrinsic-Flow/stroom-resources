#!/bin/bash

#exit script on any error
set -e

#Shell Colour constants for use in 'echo -e'
#e.g.  echo -e "My message ${GREEN}with just this text in green${NC}"
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Colour 

sudo bash -c "echo '127.0.0.1 kafka' >> /etc/hosts"
sudo bash -c "echo '127.0.0.1 hbase' >> /etc/hosts"

echo -e "TRAVIS_EVENT_TYPE:   [${GREEN}${TRAVIS_EVENT_TYPE}${NC}]"

# The version of compose that is ready installed with travis does not support v2.4 yml syntax
# so we have to update to something more recent.
echo -e "${GREEN}Removing docker-compose${NC}"
sudo rm /usr/local/bin/docker-compose

echo -e "${GREEN}Installing docker-compose ${BLUE}${DOCKER_COMPOSER_VERSION}${NC}"
curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > docker-compose
chmod +x docker-compose
sudo mv docker-compose /usr/local/bin

echo -e "${GREEN}Finished running ${BLUE}before_script${NC}"

exit 0

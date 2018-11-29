#!/bin/sh

echo "Substituting variables to generate nginx.conf"

# We need to create nginx.conf from nginx.conf.template, 
# substituting NGINX_ADVERTISED_HOST from its environment variable
# As nginx.conf contains stuff like '$proxy_add_x_forwarded_for', 
# we need to give envsubst a specific list of variables
# to substitute, else it will breake the config
# shellcheck disable=SC2016
envsubst '
    ${NGINX_ADVERTISED_HOST}
    ${STROOM_HOST}
    ${STROOM_PORT}
    ${STROOM_PROXY_HOST}
    ${STROOM_PROXY_PORT}
    ${AUTH_SERVICE_HOST}
    ${AUTH_SERVICE_PORT}
    ${AUTH_UI_URL}
    ${ANNOTATIONS_UI_URL}
    ${QUERY_ELASTIC_UI_URL}
    ${NGINX_SSL_VERIFY_CLIENT}
    ${NGINX_SSL_CERTIFICATE}
    ${NGINX_SSL_CERTIFICATE_KEY}
    ${NGINX_SSL_CLIENT_CERTIFICATE}
    ${NGINX_CLIENT_BODY_BUFFER_SIZE}
    ' \
    < /stroom-nginx/config/nginx.conf.template \
    > /etc/nginx/nginx.conf

echo "Ensuring directories"
# Ensure we have the sub-directories in our /nginx/logs/ volume
mkdir -p /stroom-nginx/logs/access
mkdir -p /stroom-nginx/logs/app

crontab_file=/stroom-nginx/config/crontab.txt

if [ -f "${crontab_file}" ]; then
    echo "(Re-)setting crontab to:"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    cat "${crontab_file}"
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    # If we assign the crontab to the 'sender' user (crontab -u ...) it won't work, 
    # as sender dosn't have perms on /dev/stdout
    # Instead, consider using supercronic - https://github.com/aptible/supercronic/ so that
    # we can run as non-root
    /usr/bin/crontab "${crontab_file}"

    # start crond as root
    echo "Starting crond in the background"
    # TODO make it log to stdout/err
    exec /usr/sbin/crond -l 8
else
    echo "Warning: crontab file ${crontab_file} not found"
fi

echo "Finished docker-entrypoint, about to run CMD"

# Now run the CMD
exec "$@"

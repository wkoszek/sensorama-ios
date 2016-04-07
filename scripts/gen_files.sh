#!/bin/sh

[ -z "$FABRIC_API_KEY" ] && echo "FABRIC_API_KEY can't be empty" && exit 1
[ -z "$FABRIC_BUILD_SECRET" ] && echo "FABRIC_BUILD_SECRET can't be empty" && exit 1

BUILD_INFO="`date +%Y%m%d.%H%M`;`hostname`;`whoami`(`id -u`)"

echo "const static char *BUILD_INFO = \"$BUILD_INFO\";"
echo "const static char *FABRIC_API_KEY = \"$FABRIC_API_KEY\";"
echo "const static char *FABRIC_BUILD_SECRET = \"$FABRIC_BUILD_SECRET\";"
echo "const static char *SENSORAMA_COGNITO_POOL_ID = \"$SENSORAMA_COGNITO_POOL_ID\";"
echo "const static char *AUTH0CLIENTID = \"$AUTH0CLIENTID\";"
echo "const static char *AUTH0DOMAIN = \"$AUTH0DOMAIN\";"
echo "const static char *AUTH0_URLSCHEME = \"$AUTH0_URLSCHEME\";"
echo "const static char *SENSORAMA_DEV_PHONE = \"$SENSORAMA_DEV_PHONE\";"
echo "const static char *SENSORAMA_COGNITO_AUTH_ROLE_ARN = \"$SENSORAMA_COGNITO_AUTH_ROLE_ARN\";"

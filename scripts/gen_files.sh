#!/bin/sh

env_gen () {
	VARNAME=$1
	eval VARVAL="\$$VARNAME"
	if [ -z "$VARVAL" ]; then
		echo "// $VARNAME is empty!!!! Project may not work as expected" | tee .wrong_env_vars
		VARVAL=""
	fi
	echo "const static char *$VARNAME = \"$VARVAL\";"
}

BUILD_INFO="`date +%Y%m%d.%H%M`;`hostname`;`whoami`(`id -u`)"

#env_gen TO_TEST_DONT_EXIST
env_gen BUILD_INFO
env_gen FABRIC_API_KEY
env_gen FABRIC_BUILD_SECRET
env_gen SENSORAMA_COGNITO_POOL_ID
env_gen AUTH0CLIENTID
env_gen AUTH0DOMAIN
env_gen AUTH0_URLSCHEME
env_gen SENSORAMA_DEV_PHONE
env_gen SENSORAMA_COGNITO_AUTH_ROLE_ARN
env_gen SENSORAMA_MAILGUN_API_KEY

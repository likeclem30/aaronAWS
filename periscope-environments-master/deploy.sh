#!/bin/bash -xe

export PATH="$CHEF_RUBY:$PATH"
knife environment from file "environments/$CHEF_ENV-$TENANT_ID.json" -c $CHEF_CONFIG_FILE
if [ "$UPDATE_DATA_BAGS" = "true" ]; then
	knife data bag from file "$CHEF_ENV-$TENANT_ID" $(find data_bags/$CHEF_ENV-$TENANT_ID -type f ! -name '*-secrets.json') -c $CHEF_CONFIG_FILE
fi

knife upload /roles -c $CHEF_CONFIG_FILE
knife ssl fetch -c $CHEF_CONFIG_FILE

if [ "$BERKS_UPDATE" = "true" ]; then
    echo "Running berks update"
    berks update -b $BERKSFILE_PATH
else
    echo "Running berks install"
    berks install -b $BERKSFILE_PATH
fi

berks vendor -b $BERKSFILE_PATH
berks upload --no-freeze -b $BERKSFILE_PATH --no-ssl-verify -c $BERKS_CONFIG_FILE
berks apply $CHEF_ENV-$TENANT_ID -b $BERKSFILE_PATH.lock --no-ssl-verify -c $BERKS_CONFIG_FILE

if [ "$DEBUG_MODE" = "true" ]; then
	chef-client -z -r "recipe[periscope_infra::setup]" -E $CHEF_ENV-$TENANT_ID  -l debug --force-formatter --lockfile /tmp/mysetup_${timestamp}.pid -c ${CHEF_CONFIG_FILE}
else
	chef-client -z -r "recipe[periscope_infra::setup]" -E $CHEF_ENV-$TENANT_ID --force-formatter --lockfile /tmp/mysetup_${timestamp}.pid -c ${CHEF_CONFIG_FILE}
fi

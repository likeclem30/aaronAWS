#!/bin/bash -ex

PULL=$1

if [[ "$PULL" = true ]]; then
	# Use the master branch
	git checkout master
	# Pull the changes from upstream (infra/chef-ppv repo, branch release-1.0)
	git pull --rebase infra release-1.0
	# Push the changes to the ppv-infra master remote
	git push origin master
fi
# Use the release branch
git checkout release
# Merge the changes from the master branch
git merge master
# Update the cookbooks in the berks-cookbooks folder (check the Berksfile first)
berks vendor
# Add and commit the changes to the berks-cookbooks folder
git add berks-cookbooks && git commit -m "Updates cookbooks" || echo "No changes to cookbooks"
# Push the changes to the remote release branch
git push origin release
# Go back to master branch
git checkout master

#!/bin/bash
source /tmp/icp-bootmaster-scripts/functions.sh

# Figure out the version
# This will populate $org $repo and $tag
parse_icpversion ${1}
echo "org=$org repo=$repo tag=$tag"
echo "Got first parameter $1" 
tag1=$1

docker run -e LICENSE=accept --net=host -t -v /opt/ibm/cluster:/installer/cluster ${org}/${repo}:${tag1} install

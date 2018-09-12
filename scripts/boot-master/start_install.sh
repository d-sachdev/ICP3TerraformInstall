#!/bin/bash
source /tmp/icp-bootmaster-scripts/functions.sh

# Figure out the version
# This will populate $org $repo and $tag
parse_icpversion ${1}
echo "org=$org repo=$repo tag=$tag"
echo "Got first parameter $1" 
echo "Got second parameter $2"

tag1=$1
arch=$2

docker run -e LICENSE=accept --net=host -t -v /opt/ibm/cluster:/installer/cluster ${org}/${repo}-${arch}:${tag1} install

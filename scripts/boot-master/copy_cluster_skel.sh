#!/bin/bash
#LOGFILE=/tmp/copyclusterskel.log
#exec  > $LOGFILE 2>&1

echo "Got first parameter $1"
echo "Got second parameter $2"
tag1=$1
arch=$2
echo "Arch = $arch"

source /tmp/icp-bootmaster-scripts/functions.sh

# Figure out the version
# This will populate $org $repo and $tag
parse_icpversion ${1}
echo "org=$org repo=$repo tag=$tag"


docker run -e LICENSE=accept -v /opt/ibm:/data ${org}/${repo}-${arch}:${tag1} cp -r cluster /data

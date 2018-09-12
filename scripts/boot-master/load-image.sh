#!/bin/bash
LOGFILE=/tmp/loadimage.log
exec  > $LOGFILE 2>&1
echo "====="
echo "Got first parameter $1"
echo "Second parameter $2"
echo "Third parameter $3"
image=$1
image_file=$2
image_location=$3

echo "image_location $image_location"
df -h
sourcedir=/opt/ibm/cluster/images

source /tmp/icp-bootmaster-scripts/functions.sh

#     image_location = "nfs:169.53.48.108:/storage/software/ibm-cloud-private-x86_64-2.1.0.3-ee.tar.gz"
# Figure out the version
# This will populate $org $repo and $tag
parse_icpversion ${image}
echo "registry=${registry:-not specified} org=$org repo=$repo tag=$tag"

if [[ "${image_location}" != "" ]]; then
  echo "Using image_location" 
  # Decide which protocol to use
  if [[ "${image_location:0:3}" == "nfs" ]]; then
    # Separate out the filename and path
    nfs_mount=$(dirname ${image_location:4})
    echo "NFS mount $nfs_mount"
    image_file="${sourcedir}/$(basename ${image_location})"
    echo "New image_file $image_file"
    echo "sourcedir $sourcedir"
    mkdir -p ${sourcedir}
    # Mount
    sudo mount.nfs $nfs_mount $sourcedir
    df -h
  elif [[ "${image_location:0:4}" == "http" ]]; then
    # Figure out what we should name the file
    filename="ibm-cloud-private-x86_64-${tag%-ee}.tar.gz"
    mkdir -p ${sourcedir}
    wget --continue -O ${sourcedir}/${filename} "${image_location#http:}"
    image_file="${sourcedir}/${filename}"
  fi
fi

echo "--==--==-- image_file ::  $image_file"
#if [[ -s "$image_file" ]]; then
if [[ "$image_file" != "" ]]; then
  echo "untar the image intall file"
  tar xf ${image_file} -O | sudo docker load
else
  echo "Going the CE route"
  # If we don't have an image locally we'll pull from docker registry
  if [[ -z $(docker images -q ${registry}${registry:+/}${org}/${repo}:${tag}) ]]; then
    # If this is a private registry we may need to log in
    if [[ ! -z "$username" ]]; then
      docker login -u ${username} -p ${password} ${registry}
    fi 
    # ${registry}${registry:+/} adds <registry>/ only if registry is specified
    docker pull ${registry}${registry:+/}${org}/${repo}:${tag}
  fi
fi

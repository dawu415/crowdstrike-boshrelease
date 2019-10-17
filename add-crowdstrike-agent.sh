#!/bin/bash

set +eux 
bosh init-release

filename=$(basename $1)
version=$(echo $filename | sed -e 's/[a-zA-Z-]*_//' -e 's/_.*//')
bosh add-blob $1 ${filename}

bosh int ./packages/crowdstrike-agent/spec \
     --var=crowdstrike_deb_file=${filename} > ./install/tmp

mv ./install/tmp ./packages/crowdstrike-agent/spec
bosh int runtime-config/crowdstrike.yml \
     --var=crowdstrike_version=${version} \
     --var=customer_id=$2 > generated_runtime_config.yml

rm -rf ./config/final.yml

cat << EOF >> ./config/final.yml
blobstore:
  provider: local
  options:
    blobstore_path: $3
EOF

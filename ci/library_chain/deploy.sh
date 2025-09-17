#!/bin/sh

LIBRARY_NAME=$1

EXISTING=`curl -sS "$LIBRARY_CHAIN_API_URL/query/$LIBRARY_CHAIN_BRID?type=library_chain_versioning.get_latest_library_version&lib_id=com.chromia.$LIBRARY_NAME"`
DESCRIPTION=`echo $EXISTING | jq -r '.version_description'`

BRID_EXISTING=`echo $EXISTING | jq -r '.rid'`
BRID_NEW=`xmllint --xpath 'string(/dict/entry[@key="rid"]/bytea)' build/$LIBRARY_NAME.xml`

if [[ "$BRID_EXISTING" == "$BRID_NEW" ]]; then
   echo "Skipping deployment of $LIBRARY_NAME, because the BRID has not changed: $BRID_EXISTING."
else
   echo "Deploying $LIBRARY_NAME..."
   echo "previous BRID: $BRID_EXISTING"
   echo "new BRID: $BRID_NEW"

   chr library deploy \
      --library $LIBRARY_NAME \
      --id com.chromia.$LIBRARY_NAME \
      --version $CI_COMMIT_TAG \
      --brid $LIBRARY_CHAIN_BRID \
      --description "$DESCRIPTION" \
      --url $LIBRARY_CHAIN_API_URL
fi

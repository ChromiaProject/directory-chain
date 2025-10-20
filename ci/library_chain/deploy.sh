#!/bin/sh

LIBRARY_NAME=$1

RID_NEW=`xmllint --xpath 'string(/dict/entry[@key="rid"]/bytea)' build/$LIBRARY_NAME.xml`

EXISTING=`curl -sS "$LIBRARY_CHAIN_API_URL/query/$LIBRARY_CHAIN_BRID?type=library_chain_versioning.get_latest_library_version&lib_id=com.chromia.$LIBRARY_NAME"`

RID_EXISTING=`echo $EXISTING | jq -r '.rid'`
if [ "$RID_EXISTING" = "null" ]; then
  echo "First deploy of library $LIBRARY_NAME"
  VERSION=$2
  DESCRIPTION=$3

  echo "Creating $LIBRARY_NAME $VERSION..."
  echo "RID: $RID_NEW"

  chr library create \
    --url "$LIBRARY_CHAIN_API_URL" \
    --brid "$LIBRARY_CHAIN_BRID" \
    --library "$LIBRARY_NAME" \
    --organization com.chromia \
    --name "$LIBRARY_NAME" \
    --version "$VERSION" \
    --description "$DESCRIPTION"
else
  VERSION=${2:-$CI_COMMIT_TAG}
  DESCRIPTION=`echo $EXISTING | jq -r '.version_description'`

  if [ "$RID_EXISTING" = "$RID_NEW" ]; then
     echo "Skipping deployment of $LIBRARY_NAME, because the RID has not changed: $RID_EXISTING."
     exit 0
  fi

  VERSION_EXISTING=`echo $EXISTING | jq -r '.version'`
  if [ "$VERSION_EXISTING" = "$VERSION" ]; then
     echo "Skipping deployment of $LIBRARY_NAME, because the version has not changed: $VERSION."
     exit 0
  fi

  echo "previous RID: $RID_EXISTING"

  echo "Deploying $LIBRARY_NAME $VERSION..."
  echo "new RID: $RID_NEW"

  chr library deploy \
    --url "$LIBRARY_CHAIN_API_URL" \
    --brid "$LIBRARY_CHAIN_BRID" \
    --library "$LIBRARY_NAME" \
    --id "com.chromia.$LIBRARY_NAME" \
    --version "$VERSION" \
    --description "$DESCRIPTION"
fi

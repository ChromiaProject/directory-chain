#!/bin/sh -eu

RELEASE_DOTENV_FILE="${CI_PROJECT_DIR}/.library_chain_releases.env"

function append_release {
  version="$1"

  echo "Appending $LIBRARY_NAME v$version to library chain release variable"

  release_value=";$LIBRARY_NAME:$version"
  if grep -q LIBRARY_CHAIN_RELEASES "$RELEASE_DOTENV_FILE" &> /dev/null; then
    sed -i "s/^LIBRARY_CHAIN_RELEASES=.*/&;$release_value/" "$RELEASE_DOTENV_FILE"
  else
    echo "LIBRARY_CHAIN_RELEASES=$release_value" > "$RELEASE_DOTENV_FILE"
  fi
}

while [ "$#" -gt 0 ]; do
    case $1 in
        -n|--name) LIBRARY_NAME="$2"; shift ;;
        --major) MAJOR_VERSION="$2"; shift ;;
        --minor) MINOR_VERSION="$2"; shift ;;
        --library-description) LIBRARY_DESCRIPTION="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "Library: $LIBRARY_NAME"
echo "Major: $MAJOR_VERSION"
echo "Minor: $MINOR_VERSION"
if [ -n "${LIBRARY_DESCRIPTION+x}" ]; then
  echo "Library description: $LIBRARY_DESCRIPTION"
fi
echo

XML_CONF="build/$LIBRARY_NAME.xml"
if [ ! -f "$XML_CONF" ]; then
  echo "Missing configuration: $XML_CONF"
  exit 1
fi

RID_NEW=`xmllint --xpath 'string(/dict/entry[@key="rid"]/bytea)' "$XML_CONF"`
EXISTING=`curl -sS "$LIBRARY_CHAIN_API_URL/query/$LIBRARY_CHAIN_BRID?type=library_chain_versioning.get_latest_library_version&lib_id=com.chromia.$LIBRARY_NAME"`

RID_EXISTING=`echo $EXISTING | jq -r '.rid'`
if [ "$RID_EXISTING" = "null" ]; then

  if [ -z "${LIBRARY_DESCRIPTION+x}" ]; then
    echo "Library description is required for first deployment"
    exit 1
  fi

  echo "First deploy of library $LIBRARY_NAME"

  VERSION="$MAJOR_VERSION.$MINOR_VERSION.0"
  echo "Creating $LIBRARY_NAME $VERSION..."
  echo "RID: $RID_NEW"

  chr library create \
    --url "$LIBRARY_CHAIN_API_URL" \
    --brid "$LIBRARY_CHAIN_BRID" \
    --library "$LIBRARY_NAME" \
    --organization com.chromia \
    --name "$LIBRARY_NAME" \
    --version "$VERSION" \
    --description "$LIBRARY_DESCRIPTION"

  append_release "$VERSION"
else

  if [ "$RID_EXISTING" = "$RID_NEW" ]; then
     echo "Skipping deployment of $LIBRARY_NAME, because the RID has not changed: $RID_EXISTING."
     exit 0
  fi

  EXISTING_VERSION="$(echo $EXISTING | jq -r '.version')"
  echo "Current library version: $EXISTING_VERSION"

  EXISTING_MAJOR=${EXISTING_VERSION%%.*}
  EXISTING_VERSION_NO_MAJOR=${EXISTING_VERSION#*.}
  EXISTING_MINOR=${EXISTING_VERSION_NO_MAJOR%%.*}
  EXISTING_PATCH=${EXISTING_VERSION_NO_MAJOR#*.}

  MAJOR_MINOR_PREFIX="$MAJOR_VERSION.$MINOR_VERSION."
  if [ "${EXISTING_VERSION#$MAJOR_MINOR_PREFIX}" != "${EXISTING_VERSION}" ]; then
    NEW_PATCH="$((EXISTING_PATCH + 1))"
  else
    NEW_PATCH=0
  fi

  VERSION="$MAJOR_VERSION.$MINOR_VERSION.$NEW_PATCH"
  echo "New version: $VERSION"
  echo

  VERSION_EXISTING=`echo $EXISTING | jq -r '.version'`
  if [ "$VERSION_EXISTING" = "$VERSION" ]; then
     echo "Skipping deployment of $LIBRARY_NAME, because the version has not changed: $VERSION."
     exit 0
  fi

  DESCRIPTION=`echo $EXISTING | jq -r '.version_description'`

  echo "Deploying $LIBRARY_NAME $VERSION..."
  echo "previous RID: $RID_EXISTING"
  echo "new RID: $RID_NEW"

  chr library deploy \
    --url "$LIBRARY_CHAIN_API_URL" \
    --brid "$LIBRARY_CHAIN_BRID" \
    --library "$LIBRARY_NAME" \
    --id "com.chromia.$LIBRARY_NAME" \
    --version "$VERSION" \
    --description "$DESCRIPTION"

  append_release "$VERSION"
fi

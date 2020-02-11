if [ "$CIRCLECI" != "true" ]; then
  echo "Not building on CircleCI, skip deploy"
  exit -1
fi

if [ "$REGISTRY_URL" == "" ]; then
  echo "Registry URL not set, skip deploy"
  exit -2
fi

if [ "$DEPLOY_TOKEN" == "" ]; then
  echo "No deploy token found, skip deploy"
  exit -3
fi

#EXACT_TAG=$(git describe --exact-match --match "v*")
COMMITS_SINCE=$(git describe --match "v*" | cut -d "-" -s -f 2)

# Revision is set to nearest tag of form vX.Y
REV=$(git describe --abbrev=0 --tags --match "v*" | cut -c 2-)

CHANGE=""
if [ "$COMMITS_SINCE" != "" ]; then CHANGE=".$COMMITS_SINCE"; fi
if [ "$CIRCLE_PR_NUMBER" != "" ]; then
  CHANGE="$CHANGE-PR$CIRCLE_PR_NUMBER"
fi

SHA1=""

if [ "$REV" = "" ]
then
  echo "No valid version tag found, skip deploy"
else
  echo "Deploying release $REV$CHANGE$SHA1 to GitHub Packages"
  mvn deploy -Drevision="$REV" -Dchangelist="$CHANGE" -Dsha1="$SHA1" -Dregistry="$REGISTRY_URL" -Dtoken="$DEPLOY_TOKEN"
fi


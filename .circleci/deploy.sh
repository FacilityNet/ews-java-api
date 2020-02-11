if [ "$CIRCLECI" != "true" ]; then
  echo "Not building on CircleCI, skip deploy"
  exit -1
fi

if [ "$DEPLOY_USERNAME" == "" ]; then
  echo "Deploy username not set, skip deploy"
  exit -2
fi

if [ "$DEPLOY_PASSWORD" == "" ]; then
  echo "Deploy password not set, skip deploy"
  exit -3
fi

# Ensure we have tags available locally
git fetch --tags

#EXACT_TAG=$(git describe --exact-match --match "v*")
# Find number of commits since latest version tag
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
  mvn deploy -s shared-settings.xml -Drevision="$REV" -Dchangelist="$CHANGE" -Dsha1="$SHA1"
fi


#!/usr/bin/env bash

echo "==================================================="
echo "============= Run diffy compare and Github check =="
echo "==================================================="
COMMIT_SHA="$1"
API_KEY="$2"

DIFFY_HOST="http://stage.diffy.website"


PROJECT_ID="1195"
ENV1URL="http://diffygithubmxw6ftf7st.devcloud.acquia-sites.com/"
ENV2URL="http://diffygithubnztrwgbywl.devcloud.acquia-sites.com/"

ENV1CREDSMODE=false
ENV1CREDSUSER=''
ENV1CREDSPASS=''

ENV2CREDSMODE=false
ENV2CREDSUSER=''
ENV2CREDSPASS=''


echo "============= COMMIT_SHA =========="
echo $COMMIT_SHA

echo "============= API_KEY =========="
echo $API_KEY

echo "============= PROJECT_ID =========="
echo $PROJECT_ID


RESULT=`curl -s \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
-X POST -d '{"key":"'$API_KEY'"}' $DIFFY_HOST'/api/auth/key' \
| grep token | tr ':' ' ' | tr '}' ' ' |  awk  '{print $2}'`

TOKEN="${RESULT//\"/}"


if [[ -z "$TOKEN" ]]; then
   echo "============= Diffy authorization failed =========="
   echo $RESULT
   exit 1
else
   echo "============= Diffy authorization success ========="
   echo "============= Diffy run compare and Github check =="

   DIFF=`curl -s \
-H "Authorization: Bearer $TOKEN" \
-H "Content-Type:application/json" \
-H "Accept: application/json" \
-X POST --data @<(cat <<EOF
{
    "env1":"custom",
    "env2":"custom",
    "env1Url": "$ENV1URL",
	"env2Url": "$ENV2URL",
	"env1CredsMode": "$ENV1CREDSMODE",
	"env1CredsUser": "$ENV1CREDSUSER",
	"env1CredsPass": "$ENV1CREDSPASS",
	"env2CredsMode": "$ENV2CREDSMODE",
	"env2CredsUser": "$ENV2CREDSUSER",
	"env2CredsPass": "$ENV2CREDSPASS",
	"commitSha": "$COMMIT_SHA"
}
EOF
) \
$DIFFY_HOST"/api/projects/${PROJECT_ID}/compare"`


re='^[0-9]+$'
if ! [[ $DIFF =~ $re ]] ; then
   echo "============= Diffy compare failed ================"
   echo $DIFF
else
   echo "============= Diffy compare success ==============="
   echo "Diff ID: $DIFF"
fi
fi
echo "==================================================="
exit 0

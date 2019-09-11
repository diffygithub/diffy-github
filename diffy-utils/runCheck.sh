#!/usr/bin/env bash

echo "==================================================="
echo "============= Run diffy compare and Github check =="
echo "==================================================="

KEY=$API_KEY
PROJECTID=$PROJCT_ID
ENV1URL="http://site.com"
ENV2URL="https://site2.com/"

COMMITSHA="$1"

echo "============= COMMITSHA =========="
echo $COMMITSHA

echo "============= KEY =========="
echo $KEY

echo "============= PROJECTID =========="
echo $PROJECTID

ENV1CREDSMODE=false
ENV1CREDSUSER=''
ENV1CREDSPASS=''

ENV2CREDSMODE=false
ENV2CREDSUSER=''
ENV2CREDSPASS=''

TOKEN=`curl -s \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
-X POST -d '{"key":"'$KEY'"}' "https://app.diffy.website/api/auth/key" \
| grep token | tr ':' ' ' | tr '}' ' ' |  awk  '{print $2}'`

TOKEN="${TOKEN//\"/}"


if [[ -z "$TOKEN" ]]; then
   echo "============= Diffy authorization failed =========="
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
	"commitSha": "$COMMITSHA"
}
EOF
) \
"https://app.diffy.website/api/projects/${PROJECTID}/compare"`


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

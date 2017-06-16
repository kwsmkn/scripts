#!/bin/bash
#
# @(#) check_aws_events.sh ver.0.0.1
#
# 前提条件：
# ・AWSのIamロールに"ec2 describe-instance-status"を実行する権限が付与されている
#   http://aws.amazon.com/jp/iam/details/manage-permissions/
#
# ・AWS CLIがインストールされている
#   http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html
#
# ・jqがインストールされている
#   http://stedolan.github.io/jq/
#
# ・AWSのcredentials fileを取得し、その情報を配置している
#   (※配置場所は定数"CRED_FILE"で指定)
#
############################################################

# 実行時エラーでの停止(-e)を設定
set -e

# 定数設定
WORK_DIR=/path/to/work
CRED_FILE=/path/to/credencials_file
FROM_ADDRESS=address which send from
MAIL_ADDRESS=address which receive
SUBJECT="Event occurs!"
BODY1="here's the details."
BODY2="Instance Id, Availability Zone, Event Code, Event description, Event NotBefore, Event NotAfter"

# 環境変数の設定
ACCESS_KEY=`/bin/cat $CRED_FILE | tail -1 | cut -d',' -f2`
ACCESS_SECRET_KEY=`/bin/cat $CRED_FILE | tail -1 | cut -d',' -f3`

export AWS_ACCESS_KEY_ID=$ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$ACCESS_SECRET_KEY
export AWS_DEFAULT_REGION=ap-northeast-1
export AWS_DEFAULT_OUTPUT=json

# 実処理
# Eventsの有無を確認
ret=`/usr/bin/aws ec2 describe-instance-status --query "InstanceStatuses[?Events!=null]" | jq -r '.[] | [.InstanceId, .AvailabilityZone, .Events[].Code, .Events[].description, .Events[].NotBefore, .Events[].NotAfter]|@csv'`

# Eventsを検知したらメール発報
if [ -n "$ret" ]; then

  /usr/sbin/sendmail -t << EOF
From: ${FROM_ADDRESS}
To: ${MAIL_ADDRESS}
Subject: ${SUBJECT}

${BODY1}

${BODY2}
${ret}
EOF

fi

exit 0

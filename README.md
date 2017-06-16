# Read Me(if you have a time)
ここはスクリプト置き場となります。  
今後、配置したスクリプトについての簡易的な説明を記載していきます。  
  
## AWS
AWS CLIを使用したShell Script等を置いていきます。  
- create-ami
    - create-ami-cron.sh
    ステータスが`running`となっているEC2インスタンスからAMIを作成し、指定された一定期間を過ぎたAMIを削除するスクリプトとなります。  
    - create-ami-realtime.sh
    ステータスが`running`となっているEC2インスタンスからAMIを作成するスクリプトとなります。  

- check_aws_events.sh
EC2等のインスタンスで発生する、AWSからの再起動を要するイベント発生有無を検知し、メールで連絡を行うスクリプトとなります。  
  

#!/bin/bash

apt update -y

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
-o "/tmp/awscliv2.zip"

apt install unzip -y

cd /tmp
unzip awscliv2.zip
./aws/install

mkdir -p /home/ubuntu/logs

echo "Application Log Started" > /home/ubuntu/logs/app.log

cat <<EOF > /home/ubuntu/backup.sh
#!/bin/bash

TIMESTAMP=\$(date +"%Y%m%d-%H%M%S")

echo "\$(date)" >> /home/ubuntu/logs/app.log

aws s3 cp \
/home/ubuntu/logs/app.log \
s3://${bucket_name}/app-\$TIMESTAMP.log
EOF

chmod +x /home/ubuntu/backup.sh

(crontab -l 2>/dev/null; echo "*/1 * * * * /home/ubuntu/backup.sh") | crontab -
#!/bin/bash

scp -i ~/.ssh/demo.pem ~/Downloads/jce_policy-8.zip root@master1.hdpcloud.internal:/root/
scp -i ~/.ssh/demo.pem ~/Downloads/jce_policy-8.zip root@master2.hdpcloud.internal:/root/
scp -i ~/.ssh/demo.pem ~/Downloads/jce_policy-8.zip root@infra.hdpcloud.internal:/root/
scp -i ~/.ssh/demo.pem ~/Downloads/jce_policy-8.zip root@management.hdpcloud.internal:/root/
scp -i ~/.ssh/demo.pem ~/Downloads/jce_policy-8.zip root@slave0-1.hdpcloud.internal:/root/
scp -i ~/.ssh/demo.pem ~/Downloads/jce_policy-8.zip root@slave0-2.hdpcloud.internal:/root/
scp -i ~/.ssh/demo.pem ~/Downloads/jce_policy-8.zip root@slave0-3.hdpcloud.internal:/root/
scp -i ~/.ssh/demo.pem ~/Downloads/jce_policy-8.zip root@slave1-1.hdpcloud.internal:/root/
scp -i ~/.ssh/demo.pem ~/Downloads/jce_policy-8.zip root@slave1-2.hdpcloud.internal:/root/
scp -i ~/.ssh/demo.pem ~/Downloads/jce_policy-8.zip root@slave1-3.hdpcloud.internal:/root/
scp -i ~/.ssh/demo.pem ~/Downloads/jce_policy-8.zip root@slave1-3.hdpcloud.internal:/root/
scp -i ~/.ssh/demo.pem ~/Downloads/jce_policy-8.zip root@kafka-1.hdpcloud.internal:/root/
scp -i ~/.ssh/demo.pem ~/Downloads/jce_policy-8.zip root@kafka-2.hdpcloud.internal:/root/
scp -i ~/.ssh/demo.pem ~/Downloads/jce_policy-8.zip root@kafka-3.hdpcloud.internal:/root/
scp -i ~/.ssh/demo.pem ~/Downloads/jce_policy-8.zip root@kafka-4.hdpcloud.internal:/root/
scp -i ~/.ssh/demo.pem ~/Downloads/jce_policy-8.zip root@kafka-5.hdpcloud.internal:/root/
scp -i ~/.ssh/demo.pem ~/Downloads/jce_policy-8.zip root@dps-server.hdpcloud.internal:/root/


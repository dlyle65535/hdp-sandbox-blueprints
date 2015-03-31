#!/bin/bash

#change password for admin user 

#install ambari-agent
yum install -y ambari-agent
ambari-agent start
chkconfig ambari-agent on
sleep 10

#write hostname to hostmap file
sed -i -- s/REPLACE-ME/$(hostname -f)/g sandbox.hostmapping

#build cluster
curl -s -u admin:admin -X POST -H 'X-Requested-By: ambari' localhost:8080/api/v1/blueprints/sandbox -d @sandbox.blueprint
curl -s -u admin:admin -X POST -H 'X-Requested-By: ambari' localhost:8080/api/v1/clusters/Sandbox -d @sandbox.hostmapping 

#change ambari admin password
sed -i -- s/REPLACE-ME/$(curl http://169.254.169.254/latest/meta-data/instance-id)/g password.json
curl -s -u admin:admin -H "X-Requested-By: ambari" -i -X PUT http://localhost:8080/api/v1/users/admin -d @password.json

echo Ambari admin password is now $(curl http://169.254.169.254/latest/meta-data/instance-id)

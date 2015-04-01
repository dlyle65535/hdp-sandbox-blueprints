#!/bin/bash

show_help() {
cat << EOF
Usage: ${0##*/} [-h] [-a ambari hostname] [-c]
Deploy HDP 2.2 using blueprint    
    -h          	display this help and exit.
    -a ambari hostname  Hostname of Ambari Server in host:port format.
    -c         		Change Ambari Server password. 
EOF
}

# Initialize our own variables:
changePassword=0
ambariHost=localhost:8080
ambariServerFound=0

OPTIND=1 
while getopts "hca:" opt; do
    case "$opt" in
        h)
            show_help
            exit 0
            ;;
        c)  changePassword=1
            ;;
        a)  ambariHost=$OPTARG
            ;;
        '?')
            show_help >&2
            exit 1
            ;;
    esac
done

echo Building cluster with following options:
echo changePassword = ${changePassword}
echo ambariHost = ${ambariHost}

#wait for ambari server
ReTry=0
while [ $ReTry -lt 10 ]; do
  result=$(curl -s -o /dev/null -I -w "%{http_code}" ${ambariHost} )
  if [ $result -eq 200 ]; then
   ambariServerFound=1
   ReTry=10
  else
   echo Cannot find Ambari Server - Sleeping for 10 seconds
   sleep 10
   ReTry=$[ReTry+1]
  fi
done

if [ $ambariServerFound -eq 1 ]; then
   echo Ambari Found! Continuing.
else
   echo Ambari Server could not be found in 10 attempts - exiting.
   exit 1
fi



#install ambari-agent
yum install -y ambari-agent
ambari-agent start
chkconfig ambari-agent on
sleep 10

#write hostname to hostmap file
sed -i -- s/REPLACE-ME/$(hostname -f)/g sandbox.hostmapping

#build cluster
result=$(curl -s -o /dev/null -u admin:admin -X POST -H 'X-Requested-By: ambari' -w "%{http_code}" ${ambariHost}/api/v1/blueprints/sandbox -d @sandbox.blueprint)
if [ $result -ne 201 ]; then
   echo Could not post blueprint to Ambari Server - exiting!
   echo ambariServer: $ambariHost
   echo result: $result
   exit 1
fi

result=$(curl -s -o /dev/null -u admin:admin -X POST -H 'X-Requested-By: ambari' -w "%{http_code}" ${ambariHost}/api/v1/clusters/Sandbox -d @sandbox.hostmapping)
if [ $result -ne 202 ]; then
   echo Ambari Server could not create cluster - exiting!
   echo ambariServer: $ambariHost
   echo result: $result
   exit 1
fi

#change ambari admin password
if [ $changePassword -eq 1 ]; then
   sed -i -- s/REPLACE-ME/$(curl http://169.254.169.254/latest/meta-data/instance-id)/g password.json
   result=$(curl -s -o /dev/null -u admin:admin -H "X-Requested-By: ambari" -w "%{http_code}" -i -X PUT http://${ambariHost}/api/v1/users/admin -d @password.json)
   if [ $result -ne 200 ]; then
      echo Could not change Ambari Server admin password - exiting!
      exit 1
   fi
fi

echo "***************************************************************"
echo "****** Cluster build has begun"
echo "****** Monitor progress via ambari at ${ambariHost}"
if [ $changePassword -eq 1 ]; then
   echo "****** Ambari admin password is $(curl http://169.254.169.254/latest/meta-data/instance-id)"
fi
echo "***************************************************************"

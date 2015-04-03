# hdp-sandbox-blueprints
AMI Template for single node HDP AMI instance. Runs as ami-b25e6fda on AWS.

Blueprint can also be used to build create a cluster.

### Usage - AMI
1. Launch instance from ami-b25e6fda. Recommend m3.large or bigger. Make sure port 22 and 8080 are exposed.
2. Login to instance via ssh.
3. tail -f /var/log/hdp-setup.log.
4. Wait for Ambari password change message in log.
5. Use new Ambari password to access admin account on http://your-instance-public-hostname:8080
6. Watch cluster build progress on Ambari.
 

### Usage - Build from blueprint
1. Install/Setup/Start ambari-server and ambari-agent on your host. 
2. Change hostname in sandbox.hostmapping to your fqdn
3. Load blueprint into Ambari: 

   >`curl -u admin:admin -X POST -H 'X-Requested-By: ambari' <hostname>:8080/api/v1/blueprints/sandbox -d @sandbox.blueprint` 
4. Build cluster: 

   >`curl -u admin:admin -X POST -H 'X-Requested-By: ambari' <hostname>:8080/api/v1/clusters/<ClusterName> -d @sandbox.hostmapping`

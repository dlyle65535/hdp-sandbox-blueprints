# hdp-sandbox-blueprints
Basic single node blueprint and hostmap file to create a cluster.

### Usage
1. Install/Setup/Start ambari-server and ambari-agent on your host. 
2. Change hostname in sandbox.hostmapping to your fqdn
3. Load blueprint into Ambari: 

   `curl -u admin:admin -X POST -H 'X-Requested-By: ambari' <hostname>:8080/api/v1/blueprints/sandbox -d @sandbox.blueprint` 
4. Build cluster: 

   `curl -u admin:admin -X POST -H 'X-Requested-By: ambari' <hostname>:8080/api/v1/clusters/<ClusterName> -d @sandbox.hostmapping`

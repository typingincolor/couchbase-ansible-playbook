Couchbase Ansible Playbook with added cloudformation
====================================================

This project contains sample playbooks to manage Couchbase cluster. It also contains code to generate a cloudformation template to deploy a couchbase cluster in AWS.

Note: the current scripts are only working on Ubuntu/Debian for now

Using with cloudformation
-------------------------

You can use [cfndsl](https://github.com/stevenjack/cfndsl) to create a cloudformation template that will setup 3 t2.small instances to run couchbase.

To generate the template:

<pre>
bundle install
bundle exec cfndsl couchbase.rb > couchbase.template 
</pre>

Then upload the template file to cloudformation. You can find the IP address of the instances create by looking on the `outputs` tab in cloudformation. Then run the playbook using these IP addresses.

Add hosts file
--------------

Create a file called `hosts` using the example below:

```
[couchbase-main]
node1.local

[couchbase-nodes]
node2.local
node3.local
```

If using cloudformation, substitute in the IP address that the template outputs.

Install Couchbase cluster
--------------------------

Configure the list of Hosts in host file. 

This file contains 2 groups of server:

[couchbase-main] : select one of your server, this one will be used to initialize and configure the cluster.
[couchbase-nodes] : all other nodes that will be added to the cluster.

Enter the Administrator information and server configuration (RAM Quotas, Bucket name, Replicas) in the ./group_vars/all file

Run the Ansible command
<pre>
ansible-playbook -i ./hosts-amazon ./couchbase.yml --user=_username_ --private-key=_location_of_pem_file
</pre>


This script will do the following:
* Download the Couchbase package if not already present on all nodes
* Install the dependencies on all nodes if needed
* Install Couchbase on all nodes
* Create a new cluster on the "main" node
* Add all other nodes to the cluster
* Create a new bucket


Uninstall Couchbase Cluster
---------------------------

Uninstall the Couchbase server and delete all files (Warning you will lose your data)


Run the Ansible command
<pre>
ansible-playbook -i ./hosts ./couchbase-uninstall.yml --user=_username_ --private-key=_location_of_pem_file
</pre>



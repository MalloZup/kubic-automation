# CaaSP OpenStack Heat

This directory contains the caasp-openstack-heat tool. This tool builds a CaaSP cluster
on OpenStack with minimal effort. This tool is not suitable for development clusters, as
no code is injected into the cluster.

It's primary purpose is for building large scale CaaSP clusters on OpenStack for testing
and validation.

## Requirements

You can install the necessary dependancy packages with:

    $ sudo zypper in jq python-openstackclient python-novaclient python-heatclient

## CLI Syntax

    > ./caasp-openstack --help
    Usage:

      * Building a cluster

        -b|--build                       Run the Heat Stack Build Step
        -m|--masters             <INT>   Number of masters to build (Default: 3)
        -w|--workers             <INT>   Number of workers to build (Default: 2)
        -i|--image               <STR>   Image to use

      * Destroying a cluster

        -d|--destroy                     Run the Heat Stack Destroy Step

      * Common options

        -o|--openrc             <STR>   Path to an openrc file
        -e|--heat-environment   <STR>   Path to a heat environment file

      * Examples:

      Build a 1 master, 2 worker cluster

      ./caasp-openstack --build -m 1 -w 2 --openrc my-openrc --image CaaSP-1.0.0-GM --name test-stack

      Build a 3 master, 2 worker cluster

      ./caasp-openstack --build -m 3 -w 2 --openrc my-openrc --image CaaSP-1.0.0-GM --name test-stack

## Using a cluster

The nodes booted will all be listed in the generated environment.json file, please refer to this
file for IP addresses etc.

## Installation procedure

```
1. Download:
   a. git clone https://github.com/kubic-project/automation.git
   b. To install using heat templates:  ~/automation/caasp-openstack-heat/

2. Create DNS:
   a. From http://prvcld.caasp.suse.net create dns entry
   b. Click on DNS, Domains, Create Domain.

3. Create Network:
   a. From Engcloud: Network, Networks, Create Network.
   b. Add Network and subnet name and address.

4. Download openrc:
   a. From engcloud: Compute, access & security, API Access then click "downloaded Openstack RC File v3"
   b. Copy downloaded RC file "container-openrc.sh" to  ~/automation/caasp-openstack-heat/
   c. source container-openrc.sh

5. Check Image name from local host:
   a. Install openstack client: https://pypi.org/project/python-openstackclient/
   b. To list images from your cloud:
      openstack image list

6. Edit heat template:
   a. Copy  ~/automation/caasp-openstack-heat/heat-environment.yaml.example  to   ~/automation/caasp-openstack-heat/heat-environment.yaml
   b. Modify heat-environment.yaml:  Add address created above during create network.
      external_net: floating
      internal_net_cidr: <internal ip>

7. Command: Example for 3 workers.
   ./caasp-openstack --build -m 1 -w 3 --openrc <downloaded openstack rc> --image <image name> --name  <stack name> --heat-environment heat-environment.yaml

8. Create Records for DNS:
   a. From http://prvcld.caasp.suse.net/ select your created DNS and create record for kubernetesExternalHost and dashboardExternalHost
   b. Set record name for master - IP of master node
   c. Set record name for admin - IP of admin node

9. From Velum: Access it from https://<admin dns>
   a. Set External Kubernetes API FQDN" to "Master DNS"
   b. Set External Dashboard FQDN to "Admin DNS"
   c. Accept all nodes
   d. Bootstrap nodes
   e. Download kubeconfig on local host
   f. Set kubeconfig path. you can export path or copy it ~/.kube/config
      * Run export KUBECONFIG=~/Downloads/kubeconfig
      * OR try this mkdir ~/.kube ; cp ~/Downloads/kubeconfig ~/.kube/config


10. Test kubectl from local host:
   a. Download kubectl:
      curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
   b. Make the kubectl binary executable and copy to PATH
      chmod +x ./kubectl ; cp ./kubectl  /usr/local/bin/kubectl
   c. Run following commands from your local host:
      kubectl cluster-info
      kubectl get nodes

```

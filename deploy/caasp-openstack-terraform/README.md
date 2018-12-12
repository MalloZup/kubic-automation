# Orchestrate CaaSP on OpenStack

This is terraform orchestration for CaaSP deployment on OpenStack cloud

## Overview

We would like to have CaaSP installation on OpenStack automated. This orchestration is helping with that. After providing data about OpenStack API's and credentials, CaaSP can be easely installed with one command. After CaaSP is installed it can be also scalled up by changing number of minion Workers.

## Usage

### Requirements

Basic requirement is to have running OpenStack cloud environment. Next step is to get OpenAtack RC file with informations about OpenStack API url, user credentials and specific informations about DomaiName, RergionName and others.

It is also required to create before deployment private network called, which name has to provided in options.

#### Main options

After downloading OpenStack RC file, please source openrc.sh file which is exporting OS variables with required informations. For more options please edit openstack.tfvars and change specific options about CaaSP deployment.

#### Examples

Deploy CaaSP on OpenStack
```
./caasp-openstack apply
```

Refresh current deployment and update existing cluster after changing workers number
```
./caasp-openstack plan
./caasp-openstack apply
```

Cleanup installation
```
./caasp-openstack destroy
```

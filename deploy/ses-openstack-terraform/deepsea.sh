#!/bin/bash

zypper -n in -l -y ntp 

cat <<EOF > /etc/ntp.conf
server ntp1.suse.de
server ntp2.suse.de
server ntp3.suse.de
EOF

host=$(hostname)

/usr/bin/systemctl stop SuSEfirewall2.service
/usr/bin/systemctl enable --now ntpd.service

zypper -n in -l -y salt-master salt-minion
systemctl enable salt-master.service
systemctl start salt-master.service

cat <<EOF > /etc/salt/minion.d/master.conf
master: $host
EOF

systemctl enable salt-minion.service
systemctl start salt-minion.service
sleep 2m && salt-key -q -y --accept-all
zypper -n in -l -y deepsea

cat <<EOF > /srv/pillar/ceph/stack/global.yml
stage_prep_master: default-no-update-no-reboot
stage_prep_minion: default-no-update-no-reboot
EOF

cat <<EOF > /srv/pillar/ceph/master_minion.sls
master_minion: $host.openstack.local
EOF

cat <<EOF > /srv/pillar/ceph/deepsea_minions.sls
deepsea_minions: '*'    
EOF

echo "Running deepsea stage 0"
deepsea stage run ceph.stage.0

echo "Running deepsea stage 1"
deepsea stage run ceph.stage.1

policyf=/srv/pillar/ceph/proposals/policy.cfg

cat <<EOF > $policyf
## Cluster Assignment
cluster-ceph/cluster/*.sls
## Roles
# MASTER
role-master/cluster/ses-admin*.sls
# ADMIN
role-admin/cluster/ses-admin*.sls
# MON
role-mon/cluster/ses-mon*.sls
role-admin/cluster/ses-mon*.sls
# MGR
role-mgr/cluster/ses-mon*.sls
# MDS
role-mds/cluster/ses-mon*.sls
# COMMON
config/stack/default/global.yml 
config/stack/default/ceph/cluster.yml 
## Profiles
profile-default/cluster/ses-osd*.sls 
profile-default/stack/default/ceph/minions/ses-osd*.yml
EOF

echo "Running deepsea stage 2"
deepsea stage run ceph.stage.2

echo "Running deepsea stage 3"
deepsea stage run ceph.stage.3

echo "Running deepsea stage 4"
deepsea stage run ceph.stage.4

echo "creating k8s osd pool"
ceph osd pool create k8s 45 45

echo "output base64 ecoding of admin user"
ceph auth get-key client.admin | base64

echo "change update policy back to default"
cat <<EOF > /srv/pillar/ceph/stack/global.yml
stage_prep_master: default
stage_prep_minion: default
EOF



# Create environment.json file - see environment.json.example

from collections import Counter
import json
import logging
import os

log = logging.getLogger(__name__)

SSH_KEY_RELPATH = "automation/misc-files/id_shared"


def create_environment_json(admin_host_ipaddr, available_hosts):
    """
    First host: admin
    Second host: master
    """
    ws = os.environ.get('WORKSPACE', os.path.expanduser("~"))
    ssh_key_path = os.path.join(ws, SSH_KEY_RELPATH)

    d = {
        "dashboardHost": admin_host_ipaddr,
        "dashboardExternalHost": admin_host_ipaddr,
        "sshUser" : "root",
        "sshKey" : ssh_key_path,
        "minions": []
    }
    # FIXME: this is picking a macaddr    master_ipaddr = available_hosts[1][2]
    indexes = Counter()
    for cnt, minion in enumerate(available_hosts):
        name, hw_serial, macaddr, ipaddr, machine_id = minion
        if cnt == 0:
            role = "admin"
        elif cnt == 1:
            role = "master"
            # FIXME: This will fail for multi-master, this needs to be a round robin DNS record, or
            # a load balancer address - or at the least - a DNS name aimed at one of the masters and
            # registered in /etc/hosts on any machine who needs to reach the cluster.
            d["kubernetesExternalHost"] = ipaddr
        else:
            role = "worker"
            # unneded
            # d["minions"][-1]["proxyCommand"] = "ssh root@{} -W %h:%p".format(master_ipaddr)

        d["minions"].append({
           "minionID" : machine_id,
           "index" : str(indexes[role]),
           "fqdn" : hw_serial,
           "addresses" : {
              "privateIpv4" : ipaddr,
              "publicIpv4" : ipaddr,
           },
           "status" : "unused",
           "role": role,
        })
        # count up index for each role
        indexes.update((role,))


    fn = os.path.abspath('environment.json')
    with open(fn, 'w') as f:
        json.dump(d, f, indent=4, sort_keys=True)
    log.info('{} written'.format(fn))

#!/bin/bash
set -e
SECRET=$(ssh -i ssh/id_ses -o BatchMode=yes -o StrictHostKeyChecking=no sles@$1 sudo ceph auth get-key client.admin | base64)
jq -n --arg secret "$SECRET" '{"secret":$secret}'
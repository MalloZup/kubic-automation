#!/bin/bash

SUSEConnect -r ${regcode}
zypper --non-interactive --quiet --gpg-auto-import-keys ar -f ${ses_base} ses_base
zypper --non-interactive --quiet --gpg-auto-import-keys ar -f ${ses_update} ses_update

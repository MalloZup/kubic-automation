#!/bin/bash

zypper --non-interactive --quiet --gpg-auto-import-keys ar -f ${sles_base} sles_base
zypper --non-interactive --quiet --gpg-auto-import-keys ar -f ${sles_update} sles_update
zypper --non-interactive --quiet --gpg-auto-import-keys ar -f ${containers_module_base} containers-module_base
zypper --non-interactive --quiet --gpg-auto-import-keys ar -f ${containers_module_update} containers-module_update

cat <<EOF > /root/gencert
#!/bin/bash
openssl req  -newkey rsa:2048 -nodes -keyout domain.key -x509 -days 365 -out domain.crt \
    -subj "/C=DE/ST=Bayern/L=Nuremberg/O=SUSE Linux/OU=QA-CSS/CN=${hostdomain}/emailAddress=qa-css@suse.de"
EOF

if ${https} ; then touch /root/https_enabled ; fi;

chmod +x /root/gencert

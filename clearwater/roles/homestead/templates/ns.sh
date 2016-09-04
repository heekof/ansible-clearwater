#!/bin/bash

retries=0

while ! { nsupdate -y "{{ zone }}:{{ dnssec_key }}" -v << EOF
server {{ groups['ns'][0] }}
update add hs.{{ zone }}. 30 A {{ inventory_hostname }}
update add {{ ansible_hostname.split('-')[0] }}.{{ zone }}. 30 A {{ ansible_default_ipv4.address }}
send
EOF
} && [ $retries -lt 10 ]
do
    retries=$((retries + 1))
    echo 'nsupdate failed - retrying (retry '$retries')...'
    sleep 5
done


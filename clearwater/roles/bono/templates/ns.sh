#!/bin/bash

retries=0

while ! { nsupdate -y "{{ zone }}:{{ dnssec_key }}" -v << EOF
server {{ groups['ns'][0] }}
update add {{ zone }}. 30 A {{ inventory_hostname }}
update add {{ ansible_hostname.split('-')[0] }}.{{ zone }}. 30 A {{ inventory_hostname }}
update add {{ zone }}. 30 NAPTR 0 0 "s" "SIP+D2T" "" _sip._tcp.{{ zone }}.
update add {{ zone }}. 30 NAPTR 0 0 "s" "SIP+D2U" "" _sip._udp.{{ zone }}.
update add _sip._tcp.{{ zone }}. 30 SRV 0 0 5060 {{ ansible_hostname }}.{{ zone }}.
update add _sip._udp.{{ zone }}. 30 SRV 0 0 5060 {{ ansible_hostname }}.{{ zone }}.
send
EOF
} && [ $retries -lt 10 ]
do
    retries=$((retries + 1))
    echo 'nsupdate failed - retrying (retry '$retries')...'
    sleep 5
done


#!/bin/bash

retries=0

while ! { nsupdate -y "{{ zone }}:{{ dnssec_key }}" -v << EOF
server {{ groups['ns'][0] }}
update add {{ ansible_hostname }}.{{ zone }}. 30 A {{ ansible_default_ipv4.address }}
update add {{ ansible_hostname.split('-')[0] }}.{{ zone }}. 30 A {{ ansible_default_ipv4.address }}
update add {{ ansible_hostname.split('-')[0] }}.{{ zone }}. 30 NAPTR 0 0 "s" "SIP+D2T" "" _sip._tcp.{{ ansible_hostname.split('-')[0] }}.{{ zone }}.
update add _sip._tcp.{{ ansible_hostname.split('-')[0] }}.{{ zone }}. 30 SRV 0 0 5054 {{ ansible_hostname }}.{{ zone }}.
update add icscf.{{ ansible_hostname.split('-')[0] }}.{{ zone }}. 30 NAPTR 0 0 "s" "SIP+D2T" "" _sip._tcp.icscf.{{ ansible_hostname.split('-')[0] }}.{{ zone }}.
update add _sip._tcp.icscf.{{ ansible_hostname.split('-')[0] }}.{{ zone }}. 30 SRV 0 0 5052 {{ ansible_hostname }}.{{ zone }}.
send
EOF
} && [ $retries -lt 10 ]
do
    retries=$((retries + 1))
    echo 'nsupdate failed - retrying (retry '$retries')...'
    sleep 5
done


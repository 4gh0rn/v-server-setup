#! /bin/bash

# {{ ansible_managed }}

{% for item in iptables.rules.custom_template %}
# check if rule exists, if not insert it
iptables -C {% if item.startswith('-A') %}{{ item[2:] }}{% else %}{{ item }}{% endif %}

if [ "$?" -ne "0" ]; then
    echo 'Adding rule {{ item }}'
    iptables {{ item }};
fi
{% endfor %}
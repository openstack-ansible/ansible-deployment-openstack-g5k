#!/bin/bash

if [ "$1" = "--host" ]; then
    echo "{}"
    exit 0
fi

[ -n "$OAR_NODE_FILE" ] && nodes=($(sort -uV $OAR_NODE_FILE))
[ -f "openstack-nodes.txt" ] && nodes=($(cat harness-nodes.txt))

if [ -z "$nodes" ] || [ ${#nodes[@]} -lt 2 ]; then
    echo "{}"
    exit 0
fi

openstack_network_external_network="$(g5k-subnets -GN)/14"
openstack_network_external_gateway=$(g5k-subnets -gN)
openstack_network_external_allocation_pool_start=$(g5k-subnets -i | head -1)
openstack_network_external_allocation_pool_end=$(g5k-subnets -i | tail -1)
openstack_network_external_dns_servers=$(g5k-subnets -d | perl -lane 'print $F[-1]')

cat <<EOF
{
    "controller" : {
        "hosts" : [ "${nodes[0]}" ],
        "vars"  : {
            "ansible_ssh_user" : "root",
            "openstack_horizon_url" : "http://${nodes[0]}/horizon"
        }
    },
    "network"    : {
        "hosts" : [ "${nodes[0]}" ],
        "vars"  : {
            "ansible_ssh_user" : "root",
            "openstack_network_external_network" : "$openstack_network_external_network",
            "openstack_network_external_gateway" : "$openstack_network_external_gateway",
            "openstack_network_external_allocation_pool_start" : "$openstack_network_external_allocation_pool_start",
            "openstack_network_external_allocation_pool_end" : "$openstack_network_external_allocation_pool_end",
            "openstack_network_external_dns_servers" : "$openstack_network_external_dns_servers"
        }
    },
    "compute"    : {
        "hosts" : [ "$(echo ${nodes[@]:1} | perl -lane 'print join "\", \"", @F')" ],
        "vars"  : {
            "ansible_ssh_user" : "root"
        }
    }
}
EOF

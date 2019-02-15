PREFIX=$1

function generate()
{
        rm -Rf /tmp/opflex-config
        rm /tmp/opflex-config.tar.gz
        mkdir -p /tmp/opflex-config/var/lib
        mkdir -p /tmp/opflex-config/etc

        cp -Rf $PREFIX/var/lib/opflex-agent-ovs /tmp/opflex-config/var/lib
        cp -Rf $PREFIX/etc/opflex-agent-ovs /tmp/opflex-config/etc

        # gbp_inspect -w 100000 -fprq DmtreeRoot --socket /var/run/opflex-agent-inspect.sock  -t dump > /tmp/opflex-config/policy.json
        gbp_inspect -w 100000 -fprq DmtreeRoot -t dump > /tmp/opflex-config/policy.json

        ip link > /tmp/opflex-config/ip_link
        ip netns list > /tmp/opflex-config/ip_netns
        ovs-vsctl show > /tmp/opflex-config/ovs-vsctl-show
        ovs-ofctl show br-int > /tmp/opflex-config/ovs-ofctl-show-br-int
        ovs-ofctl show br-fabric > /tmp/opflex-config/ovs-ofctl-show-br-fabric
        ovs-ofctl show br-ex > /tmp/opflex-config/ovs-ofctl-show-br-ex
        ovs-ofctl dump-flows br-fabric -OOpenFlow13 > /tmp/opflex-config/br-fabric-flows
        ovs-ofctl dump-flows br-int -OOpenFlow13 > /tmp/opflex-config/br-int-flows
        ovs-ofctl dump-flows br-ex -OOpenFlow13 > /tmp/opflex-config/br-ex-flows
        for i in `ls /var/run/netns`; do
            echo $i
            mkdir -p /tmp/opflex-config/netns/$i
            ip netns exec $i ip link > /tmp/opflex-config/netns/$i/ip_link
            ip netns exec $i ip addr > /tmp/opflex-config/netns/$i/ip_addr
            ip netns exec $i ip route > /tmp/opflex-config/netns/$i/ip_route
            ip netns exec $i iptables-save > /tmp/opflex-config/netns/$i/iptables-save
            ip netns exec $i conntrack -L > /tmp/opflex-config/netns/$i/conntrack-list
        done
        mkdir /tmp/opflex-config/openvswitch
        cp $PREFIX/etc/openvswitch/conf.db /tmp/opflex-config/openvswitch
        ps aux | grep openvswitch > /tmp/opflex-config/openvswitch/ps-aux-openvswitch
        ps aux | grep opflex > /tmp/opflex-config/ps-aux-opflex

        cp /var/log/openvswitch/ovs-vswitchd.log /tmp/opflex-config/openvswitch
        cp /var/log/openvswitch/ovsdb-server.log /tmp/opflex-config/openvswitch
        journalctl > /tmp/opflex-config/journalctl

        cp -Rf /var/log/neutron /tmp/opflex-config/
        tar cvf /tmp/opflex-config.tar -C /tmp/ opflex-config
        gzip /tmp/opflex-config.tar
        mv /tmp/opflex-config.tar.gz /tmp/$(hostname).tar.gz
        echo "Generated /tmp/$(hostname).tar.gz"
}

generate

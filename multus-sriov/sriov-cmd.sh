#!/bin/bash
set +e

message() {
    echo "Please run:" >&2
    echo "            $0 install                install sriov-cni related" >&2
    echo "            $0 uninstall              uninstall sriov-cni related" >&2
}

install() {
    echo -e "\e[0;33minstalling sriov related resources...\e[0m"

    kubectl apply -f sriov-cni-daemonset.yaml
    kubectl apply -f sriov-device-plugin.yaml
    kubectl apply -f multus-daemonset.yaml
    kubectl apply -f sriov-cr-host-local.yaml
    kubectl apply -f sriov-cr-static.yaml
    kubectl apply -f sriov-cr-dhcp.yaml
    #kubectl apply -f sriov-cr-noipam.yaml
    sleep 1
    kubectl apply -f sriov-test-pod-host-local.yaml
    kubectl apply -f sriov-test-pod-static.yaml
    kubectl apply -f sriov-test-pod-dhcp.yaml

}

uninstall() {
    echo -e "\e[0;32muninstalling sriov related resources...\e[0m"
    
    kubectl delete -f sriov-test-pod-host-local.yaml
    kubectl delete -f sriov-test-pod-static.yaml
    kubectl delete -f sriov-test-pod-dhcp.yaml
    sleep 1
    kubectl delete -f sriov-cr-host-local.yaml
    kubectl delete -f sriov-cr-static.yaml
    kubectl delete -f sriov-cr-dhcp.yaml
    #kubectl delete -f sriov-cr-noipam.yaml
    kubectl delete -f multus-daemonset.yaml
    kubectl delete -f sriov-device-plugin.yaml
    kubectl delete -f sriov-cni-daemonset.yaml

}
<<COMMENT
MULTILINE COMMAND
COMMENT

case "$1" in
    install)
        sleep 1
        install;
        exit 0
        ;;
    uninstall)
        sleep 1
        uninstall;
        exit 0
        ;;
    *)
        message;
        exit 1
        ;;
esac
exit 0

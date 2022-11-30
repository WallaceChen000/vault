### kubernetes cni sriov test  
- environment  
    + OS: ubuntu18.04  
    + EUT: NVIDIA Mellanox MCX512A-ACAT ConnectXR-5 EN 光纖網卡 10/25GbE SFP28雙光口 PCIe 3.0x8匯流排介面 
    + driver: mlnx-en-4.7-3.2.9.0-ubuntu18.04-x86_64.tgz  
    + enable Intel `vt-d` from BIOS.  
    + enable `intel_iommu=on iommu=pt` from linux kernel arguments.  
        ```sh  
        ubuntu
        vim /etc/default/grub
        ...
        GRUB_CMDLINE_LINUX="intel_iommu=on iommu=pt"
        ...
        update-grub
        ```  
- How to setup VFs  
    ```sh 
    root@evt33:/home/evt33# lspci|grep Mell
    05:00.0 Ethernet controller: Mellanox Technologies MT27800 Family [ConnectX-5]
    05:00.1 Ethernet controller: Mellanox Technologies MT27800 Family [ConnectX-5]
    root@evt33:/home/evt33# echo 1 > /sys/class/net/ens6f0/device/sriov_numvfs
    root@evt33:/home/evt33# cat /sys/class/net/ens6f0/device/sriov_numvfs
    1
    root@evt33:/home/evt33# lspci|grep Mell
    05:00.0 Ethernet controller: Mellanox Technologies MT27800 Family [ConnectX-5]
    05:00.1 Ethernet controller: Mellanox Technologies MT27800 Family [ConnectX-5]
    05:00.2 Ethernet controller: Mellanox Technologies MT27800 Family [ConnectX-5 Virtual Function] 
    ```  
- How to check crs  
    ```sh  
    kubectl  get networkattachmentdefinition.k8s.cni.cncf.io/sriov-mlnx-dhcp -o yaml
    ```  
- How to start dhcp relay for ipam dhcp plugin?  
    ```sh  
    rm -f /run/cni/dhcp.sock && /opt/cni/bin/dhcp daemon
    ```  
    + dhcp relay log  
        ```sh  
        2022/11/29 13:43:40 5a3fc67f3572941911dbbf48956e64b5730563f4b31207f559bd572e4ecffe40/sriov-network/net1: acquiring lease
        2022/11/29 13:43:42 5a3fc67f3572941911dbbf48956e64b5730563f4b31207f559bd572e4ecffe40/sriov-network/net1: lease acquired, expiration is 2022-11-29 13:53:42.523242052 +0800 CST m=+765.359836249
        2022/11/29 13:48:42 5a3fc67f3572941911dbbf48956e64b5730563f4b31207f559bd572e4ecffe40/sriov-network/net1: renewing lease
        2022/11/29 13:48:43 5a3fc67f3572941911dbbf48956e64b5730563f4b31207f559bd572e4ecffe40/sriov-network/net1: lease renewed, expiration is 2022-11-29 13:58:43.587398846 +0800 CST m=+1066.423993134
        2022/11/29 13:51:32 5a3fc67f3572941911dbbf48956e64b5730563f4b31207f559bd572e4ecffe40/sriov-network/net1: releasing lease
        ```  
+ Where to find the test-pod's IP?
    ```yaml  
        k8s.v1.cni.cncf.io/networks: sriov-mlnx-dhcp
        k8s.v1.cni.cncf.io/networks-status: |-
        [{
            "name": "cbr0",
            "interface": "eth0",
            "ips": [
                "10.42.0.15"
            ],
            "mac": "0e:ec:2b:bc:58:39",
            "default": true,
            "dns": {}
        },{
            "name": "default/sriov-mlnx-dhcp",
            "interface": "net1",
            "ips": [
                "192.168.5.240"
            ],
            "mac": "7a:0f:75:b8:5c:b3",
            "dns": {},
            "device-info": {
                "type": "pci",
                "version": "1.0.0",
                "pci": {
                    "pci-address": "0000:05:00.6"
                }
            }
        }]
    ```  
- errors  
    + use multus cni v3.7.1 when you removes it, it causes sriov cni container is always in `terminating` state  
        ```sh  
        kube-system                kube-sriov-cni-ds-amd64-c9kfl                                    ● 0/1          0 Terminating    0   0      0      0      0  0
        ```  
        + should use k9s ctrl+k kill it  
        + change multus cni to v3.9.2 is no problem  

---
## Misc terms  
+ InfiniBand标准中有两种类型的通道配接器，一种是主通道配接器（host channel adapter；HCA），另外一种是目标通道配接器(target channel adapter;TCA)。  
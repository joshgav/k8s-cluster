# To automate

modify NetworkManager/conf.d/calico.conf to exclude `cali` and `tunl` interfaces from nm management

bypass node's /etc/resolv.conf cause it refers to 127.0.0.1
created /etc/resolv.conf.k8s and referred to it in kubeletConfigurations as kubeletConfiguration.resolvConf and as nodeRegistration.extraKubeletArgs ("--resolv-conf: /etc/resolv.conf.k8s")

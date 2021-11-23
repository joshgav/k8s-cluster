# OpenShift on libvirtd

## okd
- https://github.com/openshift/okd/blob/master/Guides/UPI/libvirt/libvirt.md
- https://github.com/openshift/okd/blob/master/Guides/UPI/vSphere_govc/Requirements/DNS_Bind.md

previous work:
  - https://github.com/openshift/installer/tree/master/docs/dev/libvirt
  - https://www.redhat.com/en/blog/installing-openshift-41-using-libvirt-and-kvm
  - https://computingforgeeks.com/how-to-deploy-openshift-container-platform-on-kvm/
  - https://luis-javier-arizmendi-alonso.medium.com/deploying-an-openshift-4-lab-in-a-kvm-node-using-libvirt-ipi-652f0476e8a5
  - https://openshift-kni.github.io/baremetal-deploy/

bare metal:
  - https://docs.openshift.com/container-platform/4.9/architecture/architecture-installation.html
  - https://docs.openshift.com/container-platform/4.9/installing/installing_bare_metal/preparing-to-install-on-bare-metal.html
practice:
  - https://docs.openshift.com/container-platform/4.9/installing/installing_bare_metal/installing-bare-metal.html

resources:
- https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/
- https://console.redhat.com/openshift/install

## Compute

- "infrastructure" - the `I` in UPI/IPI means the compute infrastructure
- "platform" as used in install-config.yaml is the provider of compute and network resources
- each machine type is configured immutably via Ignition configs loaded at boot via a volume mount

## Network

- Ensure dynamic pod interfaces are excluded from NetworkManager management. In the `[keyfile]` section of NetworkManager.conf or /etc/NetworkManager/conf.d/* use the `unmanaged-devices` key.
- DNS: configure dnsmasq.conf file and DNS server?

### UPI

- must review and sign CSRs for node serving certs
- hosts should be named and resolvable to IP addresses, as well as from IP addresses (PTR)
  - consider naming hosts via DHCP
- requires a hypervisor provider - a driver which can communicate with a provider of VMs - e.g. EC2, libvirt, Azure VMs

## Installer

- installation progresses through "targets" - states in a state machine
  - in codebase "targets" are named "assets" - see `/pkg/assets` and `/pkg/assets/targets`
- can be used to achieve just a subset of "targets"

install-config.yaml:
  - cluster name
  - base domain
  - pull secret
  - ssh public key

xCOS:
  - kubelet
  - crio
  - Ignition
  - rpm-ostree - updates delivered as ostree repo embedded in a container image

### Operators

- Machine Config Operator manages nodes
- Cluster Version Operator

## Troubleshooting
- error: cannot read /var/lib/libvirt/openshift-images/... - permission denied
  set `security_driver = 'none'` in `/etc/libvirt/qemu.conf`
- for libvirt, checkout github.com/openshift/installer to a fixed release tag, e.g. `release-4.10` and run `TAGS=libvirt hack/build.sh`

- https://github.com/openshift/installer/blob/master/docs/dev/alternative_release_image_sources.md
  - latest release: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/release.txt

- if cluster-bootstrap fails:
  - remove cluster-bootstrap container - `podman container rm cluster-bootstrap`
  - remove all static manifests at /etc/kubernetes/manifests _except_ etcd-member-pod.yaml
      `sudo rm /etc/kubernetes/manifests/{kube-apiserver-pod,kube-controller-manager-pod,kube-scheduler-pod,cloud-credential-operator-pod,bootstrap-pod}.yaml`
 
- removed /etc/hosts entry for IPv6 localhost

## Other Infrastructure

- load balancer
- image registry
- dns
- identity provider (https://docs.openshift.com/container-platform/4.9/authentication/understanding-identity-provider.html#understanding-identity-provider)
- persistent storage (https://docs.openshift.com/container-platform/4.9/storage/understanding-persistent-storage.html#understanding-persistent-storage)
- monitoring (https://docs.openshift.com/container-platform/4.9/monitoring/configuring-the-monitoring-stack.html#configuring-the-monitoring-stack)
## k8senv

Install Kubernetes clusters, controllers, and apps.

```bash
sudo -E OVERWRITE_KUBECONFIG=1 cluster/deploy.sh
```

## Notes

To configure `crictl`.

```bash
export IMAGE_SERVICE_ENDPOINT=unix:///run/containerd/containerd.sock
export CONTAINER_RUNTIME_ENDPOINT=${IMAGE_SERVICE_ENDPOINT}
```
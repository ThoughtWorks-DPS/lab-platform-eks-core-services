import json
import requests
import re
from kubernetes import client, config

# check metrics-server versions
def metrics_server_release_version():
    metrics_server_release_url = "https://api.github.com/repos/kubernetes-sigs/metrics-server/releases"
    maximum_allowed_releases_per_page = "10"
    r = requests.get(metrics_server_release_url, params={"per_page": maximum_allowed_releases_per_page})
    metrics_server_releases = json.loads(r.text)
    # filter to get metrics-server tags
    regex = re.compile("v[0-9].[0-9].[0-9]")
    latest_metrics_server_agent_version = [metrics_server_release["tag_name"] for metrics_server_release in metrics_server_releases
                                        if re.match(regex, metrics_server_release["tag_name"])]
    latest_metrics_server_version = latest_metrics_server_agent_version[0].split("-")[-1] if len(
        latest_metrics_server_agent_version) > 0 else "error"
    # latest_metrics_server_version = "d"
    return latest_metrics_server_version

def metrics_server_current_version():
    config.load_kube_config()
    v1 = client.CoreV1Api()
    metrics_server_pods = v1.list_namespaced_pod("kube-system",
                                                 label_selector="k8s-app=metrics-server")
    current_metrics_server_version = metrics_server_pods.items[0].spec.containers[0].image.split(":")[1]
    return current_metrics_server_version

current_metrics_server_version = metrics_server_current_version()
latest_metrics_server_version = metrics_server_release_version()

# check kube-state-metrics versions
def kube_state_metrics_release_version():
    kube_state_metrics_release_url = "https://github.com/kubernetes/kube-state-metrics/releases/latest"
    r = requests.get(kube_state_metrics_release_url)
    latest_kube_state_metrics_version = r.url.split("tag/")[1].replace("v", "")
    return latest_kube_state_metrics_version

def kube_state_metrics_current_version():
    config.load_kube_config()
    v1 = client.CoreV1Api()
    kube_state_metrics_pods = v1.list_namespaced_pod("kube-system",
                                                      label_selector="app.kubernetes.io/name=kube-state-metrics")
    current_kube_state_metrics_version = kube_state_metrics_pods.items[0].spec.containers[0].image.split(":v")[1]
    return current_kube_state_metrics_version

current_kube_state_metrics_version = kube_state_metrics_current_version()
latest_kube_state_metrics_version = kube_state_metrics_release_version()

# check cluster-autoscaler versions
def autoscaler_release_version():
    autoscaler_agent_release_url = "https://api.github.com/repos/kubernetes/autoscaler/releases"
    maximum_allowed_releases_per_page = "100"
    r = requests.get(autoscaler_agent_release_url, params={"per_page": maximum_allowed_releases_per_page})
    autoscaler_releases = json.loads(r.text)

    # filter to get cluster_autoscaler tags
    regex = re.compile("cluster-autoscaler-[0-9].")
    latest_autoscaler_agent_version = [autoscaler_release["tag_name"] for autoscaler_release in autoscaler_releases
                                        if re.match(regex, autoscaler_release["tag_name"])]
    latest_autoscaler_agent_tag = latest_autoscaler_agent_version[0].split("-")[-1] if len(
        latest_autoscaler_agent_version) > 0 else "error"

    return latest_autoscaler_agent_tag

def autoscaler_current_version():
    config.load_kube_config()
    v1 = client.CoreV1Api()
    autoscaler_pods = v1.list_namespaced_pod("kube-system",
                                              label_selector="app=cluster-autoscaler")
    current_autoscaler_version = autoscaler_pods.items[0].spec.containers[0].image.split(":v")[1]
    return current_autoscaler_version

current_autoscaler_version = autoscaler_current_version()
latest_autoscaler_version = autoscaler_release_version()

# check aws-efs-csi-driver versions
def efs_csi_driver_release_version():
    efs_csi_driver_release_url = "https://github.com/kubernetes-sigs/aws-efs-csi-driver/releases/latest"
    r = requests.get(efs_csi_driver_release_url)
    latest_efs_csi_driver_version = r.url.split("tag/")[1].replace("v", "")
    return latest_efs_csi_driver_version

def efs_csi_driver_current_version():
    config.load_kube_config()
    v1 = client.CoreV1Api()
    efs_csi_driver_pods = v1.list_namespaced_pod("kube-system",
                                              label_selector="app.kubernetes.io/name=aws-efs-csi-driver")
    current_efs_csi_driver_version = efs_csi_driver_pods.items[0].spec.containers[0].image.split(":v")[1]
    return current_efs_csi_driver_version

current_efs_csi_driver_version = efs_csi_driver_current_version()
latest_efs_csi_driver_version = efs_csi_driver_release_version()

latest

# log version updates available pending sercrethub (1password) expansion (don't have room for more secrets, such as Slack messaging)
if current_metrics_server_version != latest_metrics_server_version:
    print(f"New metrics-server version available: {latest_metrics_server_version}")

if current_kube_state_metrics_version != latest_kube_state_metrics_version:
    print(f"New kube-state-metrics version available: {latest_kube_state_metrics_version}")

if current_autoscaler_version != latest_autoscaler_version:
    print(f"New cluster-autoscaler version available: {latest_autoscaler_version}")

if current_efs_csi_driver_version != latest_efs_csi_driver_version:
    print(f"New efs-csi-driver version available: {latest_eks_csi_driver_version}")

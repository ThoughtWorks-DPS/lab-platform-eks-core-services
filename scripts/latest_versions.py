import json
import requests
import re
from kubernetes import client, config


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


def kube_state_metrics_release_version():
    kube_state_metrics_release_url = "https://github.com/kubernetes/kube-state-metrics/releases/latest"
    r = requests.get(kube_state_metrics_release_url)
    latest_kube_state_metrics_version = r.url.split("tag/")[1].replace("v", "")
    return latest_kube_state_metrics_version


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


def efs_csi_driver_release_version():
    efs_csi_driver_release_url = "https://github.com/kubernetes-sigs/aws-efs-csi-driver/releases/latest"
    r = requests.get(efs_csi_driver_release_url)
    latest_efs_csi_driver_version = r.url.split("tag/")[1].replace("v", "")
    return latest_efs_csi_driver_version


#=======================================================================================================================


  # "datadog-agent": "",
  # "datadog-cluster-agent": ""

latest_metrics_server_version = metrics_server_release_version()
latest_kube_state_metrics_version = kube_state_metrics_release_version()
latest_autoscaler_version = autoscaler_release_version()
latest_efs_csi_driver_version = efs_csi_driver_release_version()

latest_version = f"""
{{
  "metrics_server_version": "{metrics_server_release_version()}",
  "kube_state_metrics_version": "{kube_state_metrics_release_version()}",
  "cluster_autoscaler_version": "{autoscaler_release_version()}",
  "efs_csi_version": "{efs_csi_driver_release_version()}"
}}
"""

print(latest_version)

# write latest versions to file
with open('latest_versions.json', 'w') as outfile:
    outfile.write(latest_version)

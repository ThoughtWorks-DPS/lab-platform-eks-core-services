import json
import requests
import re
import sys
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
    kube_state_metrics_release_url = "https://api.github.com/repos/prometheus-community/helm-charts/releases"
    maximum_allowed_releases_per_page = "10"
    r = requests.get(kube_state_metrics_release_url, params={"per_page": maximum_allowed_releases_per_page})
    kube_state_metrics_releases = json.loads(r.text)

    # filter to get kube_state_metrics tags
    regex = re.compile("kube-state-metrics-[0-9].[0-9].[0-9]")
    latest_kube_state_metrics_version = [kube_state_metrics_release["tag_name"] for kube_state_metrics_release in kube_state_metrics_releases
                                        if re.match(regex, kube_state_metrics_release["tag_name"])]

    latest_kube_state_metrics_tag = latest_kube_state_metrics_version[0].split("-")[-1] if len(
        latest_kube_state_metrics_version) > 0 else "error"

    return latest_kube_state_metrics_tag

# cluster-autoscaler version must match the eks kubernetes server version minor value
# def autoscaler_release_version():
#     autoscaler_agent_release_url = "https://api.github.com/repos/kubernetes/autoscaler/releases"
#     maximum_allowed_releases_per_page = "10"
#     r = requests.get(autoscaler_agent_release_url, params={"per_page": maximum_allowed_releases_per_page})
#     autoscaler_releases = json.loads(r.text)

#     # filter to get cluster_autoscaler tags
#     regex = re.compile("cluster-autoscaler-[0-9].")
#     latest_autoscaler_agent_version = [autoscaler_release["tag_name"] for autoscaler_release in autoscaler_releases
#                                         if re.match(regex, autoscaler_release["tag_name"])]
#     latest_autoscaler_agent_tag = latest_autoscaler_agent_version[0].split("-")[-1] if len(
#         latest_autoscaler_agent_version) > 0 else "error"

#     return latest_autoscaler_agent_tag


def efs_csi_driver_release_version():
    efs_csi_driver_release_url = "https://github.com/kubernetes-sigs/aws-efs-csi-driver/releases/latest"
    r = requests.get(efs_csi_driver_release_url)
    latest_efs_csi_driver_version = r.url.split("tag/")[1].replace("v", "")
    latest_efs_csi_driver_tag = latest_efs_csi_driver_version.split("-")[-1] if len(
        latest_efs_csi_driver_version) > 0 else "error"
    return latest_efs_csi_driver_tag

def datadog_agent_release_version():
    datadog_agent_release_url = "https://api.github.com/repos/DataDog/datadog-agent/releases"
    maximum_allowed_releases_per_page = "10"
    r = requests.get(datadog_agent_release_url, params={"per_page": maximum_allowed_releases_per_page})
    datadog_agent_releases = json.loads(r.text)

    regex = re.compile("[0-9].[0-9][0-9].[0-9]")
    latest_datadog_agent_version = [datadog_agent_release["tag_name"] for datadog_agent_release in datadog_agent_releases
                                        if re.match(regex, datadog_agent_release["tag_name"])]
    latest_datadog_agent_version = latest_datadog_agent_version[0].split("-")[-1] if len(
        latest_datadog_agent_version) > 0 else "error"

    return latest_datadog_agent_version

#=======================================================================================================================


# print(metrics_server_release_version())
# print(kube_state_metrics_release_version())
# print(efs_csi_driver_release_version())
# print(datadog_agent_release_version())

latest_version = f"""
{{
  "metrics_server_version": "{metrics_server_release_version()}",
  "kube_state_metrics_version": "{kube_state_metrics_release_version()}",
  "efs_csi_version": "{efs_csi_driver_release_version()}",
  "datadog_agent_version": "{datadog_agent_release_version()}"
}}
"""

print(latest_version)

# write latest versions to file
with open('latest_versions.json', 'w') as outfile:
    outfile.write(latest_version)

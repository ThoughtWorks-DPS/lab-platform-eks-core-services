import json
import os
import sys
import requests

def set_cluster():
    clusters = ["sandbox-us-east-2", "prod-us-east-1"]
    cluster = sys.argv[1]

    if cluster not in clusters:
        raise Exception("invalid cluster. Must be one of the following: {clusters}".format(clusters=clusters))
    else:
        return cluster

cluster = set_cluster()

base_url = "https://api.datadoghq.com/api/v1/{resource}"
headers = {
    "DD-API-KEY": os.getenv("DD_API_KEY"),
    "DD-APPLICATION-KEY": os.getenv("DD_APP_KEY")
}

monitor_url = base_url.format(resource="monitor")

monitors_dir = "observe/monitors"
monitors_files = [os.path.join(monitors_dir, file) for file in os.listdir(monitors_dir) if file.endswith(".json")]

def upsert_all_monitors(cluster, monitor_url, headers, monitors_files):
    response = requests.get(monitor_url, headers=headers)
    response.raise_for_status()

    existing_monitors = {monitor["name"]: monitor for monitor in response.json()}

    for idx, monitor in enumerate(monitors_files):
        env_monitor = env_monitor_file_path(monitor)
        if os.path.exists(env_monitor):
            monitors_files[idx] = env_monitor

    for monitor_json_file in monitors_files:
        monitor_json = get_monitor(open(monitor_json_file).read(), cluster)
        if monitor_json["name"] in existing_monitors:
            monitor_id = existing_monitors[monitor_json["name"]]["id"]
            update_monitor(monitor_id, monitor_json, cluster, monitor_url, headers)
        else:
            create_monitor(monitor_json, cluster, monitor_url, headers)

def env_monitor_file_path(monitor_file):
    monitor_file_name = monitor_file.split("/")[-1]
    overwrite_file_path = "observe/monitors/{monitor}".format(monitor=monitor_file_name)
    return overwrite_file_path


def get_monitor(monitor_string, cluster):
    monitor_string = monitor_string.replace("{{ cluster }}", cluster)
    monitor_json = json.loads(monitor_string)
    return monitor_json


def update_monitor(monitor_id, monitor_json, cluster, monitor_url, headers):
    print("updating {cluster} monitor {name} with id {id}".format(cluster=cluster, name=monitor_json["name"], id=monitor_id))
    put_response = requests.put(monitor_url + "/" + str(monitor_id),
                                    headers=headers,
                                    json=monitor_json)

    put_response.raise_for_status()
    return put_response


def create_monitor(monitor_json, cluster, monitor_url, headers):
    print("creating {cluster} new monitor {name}".format(cluster=cluster, name=monitor_json["name"]))
    post_response = requests.post(monitor_url, headers=headers, json=monitor_json)
    post_response.raise_for_status()
    return post_response

upsert_all_monitors(cluster, monitor_url, headers, monitors_files)

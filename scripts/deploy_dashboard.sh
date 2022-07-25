#!/usr/bin/env bash
set -e

export TABLE_COLOR="green"
export ALERT_TABLE_COLOR="pink"

function version_alert() {
  export TABLE_COLOR=$ALERT_TABLE_COLOR
  # every 7 days, also send a slack message
  if (( "$(date +%d)" % 7 )); then
    export payload="{'text': '$1' }"
    curl -X POST -H 'Content-type: application/json' --data "$payload" $LAB_EVENTS_CHANNEL_WEBHOOK
  fi
}

# current versions table
export TABLE="| dependency | sandbox-us-east-2 | prod-us-east-1 |\\\\n|----|----|----|\\\\n"
export METRICS_SERVER_VERSIONS="| metrics-server |"
export KUBE_STATE_METRICS_VERSIONS="| kube-state-metrics* |"
export EFS_CSI_VERSIONS="| efc-csi* |"
export DATADOG_VERSIONS="| datadog-agent |"

declare -a clusters=(sandbox-us-east-2 prod-us-east-1)

echo "generate markdown table with the desired versions of the services managed by the lab-platform-eks-base pipeline for all clusters"
for cluster in "${clusters[@]}";
do
  echo $cluster
  # append environment metrics-server version
  export DESIRED_METRICS_SERVER_VERSION=$(cat environments/$cluster.auto.tfvars.json.tpl | jq -r .metrics_server_version)
  export METRICS_SERVER_VERSIONS="$METRICS_SERVER_VERSIONS $DESIRED_METRICS_SERVER_VERSION |"
  echo $DESIRED_METRICS_SERVER_VERSION

  # append environment kube-state-metrics version
  export DESIRED_KUBE_STATE_METRICS_VERSION=$(cat environments/$cluster.auto.tfvars.json.tpl | jq -r .kube_state_metrics_chart_version)
  export KUBE_STATE_METRICS_VERSIONS="$KUBE_STATE_METRICS_VERSIONS $DESIRED_KUBE_STATE_METRICS_VERSION |"
  echo $DESIRED_KUBE_STATE_METRICS_VERSION

  # append environment efs-csi-driver version
  export DESIRED_EFS_CSI_VERSION=$(cat environments/$cluster.auto.tfvars.json.tpl | jq -r .aws_efs_csi_driver_chart_version)
  export EFS_CSI_VERSIONS="$EFS_CSI_VERSIONS $DESIRED_EFS_CSI_VERSION |"
  echo $DESIRED_EFS_CSI_VERSION

  # append environment datadog-agent version
  export DESIRED_DATADOG_VERSION=$(cat environments/$cluster.auto.tfvars.json.tpl | jq -r .datadog_agent_version)
  export DATADOG_VERSIONS="$DATADOG_VERSIONS $DESIRED_DATADOG_VERSION |"
  echo $DESIRED_DATADOG_VERSION
done

# assemble markdown table
export CURRENT_TABLE="$TABLE$METRICS_SERVER_VERSIONS\\\\n$KUBE_STATE_METRICS_VERSIONS\\\\n$EFS_CSI_VERSIONS\\\\n$DATADOG_VERSIONS\\\\n\\\\n*helm chart version  \\\\nReview datadog chart version on agent change  \\\\ncluster-autoscaler version should match eks k8s version"

# current versions table
declare TABLE="| available |\\\\n|----|\\\\n"
export METRICS_SERVER_VERSIONS="| metrics-server |"
export KUBE_STATE_METRICS_VERSIONS="| kube-state-metrics |"
export EFS_CSI_VERSIONS="| efc-csi |"
export DATADOG_VERSIONS="| datadog-agaent |"

echo "generate markdown table with the available versions of the services managed by the lab-platform-eks-base pipeline for all clusters"

# fetch the latest release versions
python scripts/latest_versions.py

export LATEST_METRICS_SERVER_VERSION=$(cat latest_versions.json | jq -r .metrics_server_version)
export LATEST_KUBE_STATE_METRICS_VERSION=$(cat latest_versions.json | jq -r .kube_state_metrics_version)
export LATEST_EFS_CSI_VERSION=$(cat latest_versions.json | jq -r .efs_csi_version)
export LATEST_DATADOG_VERSION=$(cat latest_versions.json | jq -r .datadog_agent_version)

# assemble markdown table
export LATEST_TABLE="$TABLE$LATEST_METRICS_SERVER_VERSION\\\\n$LATEST_KUBE_STATE_METRICS_VERSION\\\\n$LATEST_EFS_CSI_VERSION\\\\n$LATEST_DATADOG_VERSION\\\\n"

echo "check desired production versions against latest"

if [[ $DESIRED_METRICS_SERVER_VERSION != $LATEST_METRICS_SERVER_VERSION ]]; then
  version_alert "New metrics-server version available: $LATEST_METRICS_SERVER_VERSION"
fi
# if [[ $DESIRED_KUBE_STATE_METRICS_VERSION != $LATEST_KUBE_STATE_METRICS_VERSION ]]; then
#   version_alert "New kube-state-metrics version available: $LATEST_KUBE_STATE_METRICS_VERSION"
# fi
if [[ $DESIRED_EFS_CSI_VERSION != $LATEST_EFS_CSI_VERSION ]]; then
  version_alert "New efs-csi-driver version available: $LATEST_EFS_CSI_VERSION"
fi
if [[ $DESIRED_DATADOG_VERSION != $LATEST_DATADOG_VERSION ]]; then
  version_alert "New datadog-agent version available: $LATEST_DATADOG_VERSION"
fi

echo "insert markdown into dashboard.json"
cp tpl/dashboard.json.tpl observe/dashboard.json

if [[ $(uname) == "Darwin" ]]; then
  gsed -i "s/CURRENT_TABLE/$CURRENT_TABLE/g" observe/dashboard.json
  gsed -i "s/LATEST_TABLE/$LATEST_TABLE/g" observe/dashboard.json
  gsed -i "s/TABLE_COLOR/$TABLE_COLOR/g" observe/dashboard.json
else
  sed -i "s/CURRENT_TABLE/$CURRENT_TABLE/g" observe/dashboard.json
  sed -i "s/LATEST_TABLE/$LATEST_TABLE/g" observe/dashboard.json
  sed -i "s/TABLE_COLOR/$TABLE_COLOR/g" observe/dashboard.json
fi

python scripts/dashboard.py

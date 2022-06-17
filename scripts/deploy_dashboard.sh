#!/usr/bin/env bash
set -e

export TABLE_COLOR="green"
export ALERT_TABLE_COLOR="pink"

function version_alert() {
  export TABLE_COLOR=$ALERT_TABLE_COLOR
  # every 7 days, also send a slack message
  if (( "$(date +%d)" % 7 )); then
    curl -X POST -H 'Content-type: application/json' --data '{"Notice":"$1"}' $SLACK_LAB_EVENTS
  fi
}

export AWS_DEFAULT_REGION=$(cat sandbox.auto.tfvars.json | jq -r .aws_region)
export AWS_ASSUME_ROLE=$(cat sandbox.auto.tfvars.json | jq -r .aws_assume_role)
export AWS_ACCOUNT_ID=$(cat sandbox.auto.tfvars.json | jq -r .aws_account_id)

echo "debug:"
echo "AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION"
echo "AWS_ASSUME_ROLE=$AWS_ASSUME_ROLE"
echo "AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID"
# echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:0:5}"

aws sts assume-role --output json --role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/$AWS_ASSUME_ROLE --role-session-name lab-platform-eks-core-services > credentials

export AWS_ACCESS_KEY_ID=$(cat credentials | jq -r ".Credentials.AccessKeyId")
export AWS_SECRET_ACCESS_KEY=$(cat credentials | jq -r ".Credentials.SecretAccessKey")
export AWS_SESSION_TOKEN=$(cat credentials | jq -r ".Credentials.SessionToken")

# current versions table
export TABLE="| dependency | sandbox-us-east-2 | prod-us-east-1 |\\\\n|----|----|----|\\\\n"
export METRICS_SERVER_VERSIONS="| metrics-server |"
export KUBE_STATE_METRICS_VERSIONS="| kube-state-metrics |"
export CLUSTER_AUTOSCALER_VERSIONS="| cluster-autoscaler |"
export EFS_CSI_VERSIONS="| efc-csi |"

declare -a clusters=(sandbox-us-east-2 prod-us-east-1)

echo "generate markdown table with the desired versions of the services managed by the lab-platform-eks-base pipeline for all clusters"
for cluster in "${clusters[@]}";
do
  # append environment metrics-server version
  export DESIRED_METRICS_SERVER_VERSION=$(cat environments/$cluster.auto.tfvars.json.tpl | jq -r .metrics_server_version)
  export METRICS_SERVER_VERSIONS="$METRICS_SERVER_VERSIONS $DESIRED_METRICS_SERVER_VERSION |"
  echo $DESIRED_METRICS_SERVER_VERSION

  # append environment kube-state-metrics version
  export DESIRED_KUBE_STATE_METRICS_VERSION=$(cat environments/$cluster.auto.tfvars.json.tpl | jq -r .kube_state_metrics_version)
  export KUBE_STATE_METRICS_VERSIONS="$KUBE_STATE_METRICS_VERSIONS $DESIRED_KUBE_STATE_METRICS_VERSION |"
  echo $DESIRED_KUBE_STATE_METRICS_VERSION

  # append environment cluster-autoscaler version
  export DESIRED_CLUSTER_AUTOSCALER_VERSION=$(cat environments/$cluster.auto.tfvars.json.tpl | jq -r .cluster_autoscaler_version)
  export CLUSTER_AUTOSCALER_VERSIONS="$CLUSTER_AUTOSCALER_VERSIONS $DESIRED_CLUSTER_AUTOSCALER_VERSION |"
  echo $DESIRED_CLUSTER_AUTOSCALER_VERSION

  # append environment efs-csi-driver version
  export DESIRED_EFS_CSI_VERSION=$(cat environments/$cluster.auto.tfvars.json.tpl | jq -r .aws_efs_csi_driver_version)
  export EFS_CSI_VERSIONS="$EFS_CSI_VERSIONS $DESIRED_EFS_CSI_VERSION |"
  echo $DESIRED_EFS_CSI_VERSION
done

# assemble markdown table
export CURRENT_TABLE="$TABLE$METRICS_SERVER_VERSIONS\\\\n$KUBE_STATE_METRICS_VERSIONS\\\\n$CLUSTER_AUTOSCALER_VERSIONS\\\\n$EFS_CSI_VERSIONS\\\\n"

# current versions table
declare TABLE="| available |\\\\n|----|\\\\n"
export METRICS_SERVER_VERSIONS="| metrics-server |"
export KUBE_STATE_METRICS_VERSIONS="| kube-state-metrics |"
export CLUSTER_AUTOSCALER_VERSIONS="| cluster-autoscaler |"
export EFS_CSI_VERSIONS="| efc-csi |"

echo "generate markdown table with the available versions of the services managed by the lab-platform-eks-base pipeline for all clusters"

# fetch the latest release versions
python scripts/latest_versions.py

export LATEST_METRICS_SERVER_VERSION=$(cat latest_versions.json | jq -r .metrics_server_version)
export LATEST_KUBE_STATE_METRICS_VERSION=$(cat latest_versions.json | jq -r .kube_state_metrics_version)
export LATEST_CLUSTER_AUTOSCALER_VERSION=$(cat latest_versions.json | jq -r .cluster_autoscaler_version)
export LATEST_EFS_CSI_VERSION=$(cat latest_versions.json | jq -r .efs_csi_version)

# assemble markdown table
export LATEST_TABLE="$TABLE$LATEST_METRICS_SERVER_VERSION\\\\n$LATEST_KUBE_STATE_METRICS_VERSION\\\\n$LATEST_CLUSTER_AUTOSCALER_VERSION\\\\n$LATEST_EFS_CSI_VERSION\\\\n"

echo "check desired production versions against latest"

if [[ $DESIRED_METRICS_SERVER_VERSION != $LATEST_METRICS_SERVER_VERSION ]]; then
  version_alert "New metrics-server version available: $LATEST_METRICS_SERVER_VERSION"
fi
if [[ $DESIRED_KUBE_STATE_METRICS_VERSION != $LATEST_KUBE_STATE_METRICS_VERSION ]]; then
  version_alert "New kube-state-metrics version available: $LATEST_KUBE_STATE_METRICS_VERSION"
fi
if [[ $DESIRED_CLUSTER_AUTOSCALER_VERSION != $LATEST_CLUSTER_AUTOSCALER_VERSION ]]; then
  version_alert "New cluster-autoscaler version available: $LATEST_CLUSTER_AUTOSCALER_VERSION"
fi
if [[ $DESIRED_EFS_CSI_VERSION != $LATEST_EFS_CSI_VERSION ]]; then
  version_alert "New efs-csi-driver version available: $LATEST_EFS_CSI_VERSION"
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

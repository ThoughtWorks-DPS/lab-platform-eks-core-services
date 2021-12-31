#!/usr/bin/env bash
set -e

export CLUSTER=$1
export AWS_ACCOUNT_ID=$(cat $CLUSTER.auto.tfvars.json | jq -r .account_id)
export AWS_DEFAULT_REGION=$(cat $CLUSTER.auto.tfvars.json | jq -r .aws_region)
export AWS_ASSUME_ROLE=$(cat $CLUSTER.auto.tfvars.json | jq -r .assume_role)
aws sts assume-role --output json --role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/$AWS_ASSUME_ROLE --role-session-name cluster-base-configuration-test > credentials

aws configure set aws_access_key_id $(cat credentials | jq -r ".Credentials.AccessKeyId") --profile $AWS_ASSUME_ROLE
aws configure set aws_secret_access_key $(cat credentials | jq -r ".Credentials.SecretAccessKey") --profile $AWS_ASSUME_ROLE
aws configure set aws_session_token $(cat credentials | jq -r ".Credentials.SessionToken") --profile $AWS_ASSUME_ROLE

# Get number of nodes in the cluster
NUMNODES=$(kubectl get nodes | tail -n +2 | wc -l)
echo "${NUMNODES} nodes in the cluster"

if (( NUMNODES == 1 )); then
        echo "Only one node in the cluster; recommend adding additional nodes"
        exit 1
fi

# Replace 1/4 of the nodes, rounding up
let TOREPLACE=$(((NUMNODES / 4) + (NUMNODES % 4 > 0)))
echo ${TOREPLACE} nodes will be replaced:

# Nodes to be replaced, sorted by creation date/time
REPLACENODES=( $(kubectl get nodes --sort-by=.metadata.creationTimestamp | tail -n +2 | head -${TOREPLACE} | awk '{ print $1 }') )
printf '%s\n' "${REPLACENODES[@]}"

for i in "${REPLACENODES[@]}"
do
        echo Replacing $i
        kubectl drain $i --ignore-daemonsets --delete-emptydir-data

        INSTANCE_ID=$(aws ec2 describe-instances --filter Name=private-dns-name,Values=$i --profile $AWS_ASSUME_ROLE | jq -r '.Reservations[].Instances[] | .InstanceId')
        aws ec2 stop-instances --instance-ids ${INSTANCE_ID} --profile $AWS_ASSUME_ROLE

        CURRENT_READY_NODE_COUNT=$(kubectl get nodes | awk '{ print $2 }' | grep -E '(^|\s)Ready($|\s)' | wc -l)

        # Wait until Ready node count is equal to starting number of nodes
        until [ $CURRENT_READY_NODE_COUNT == $NUMNODES ]
        do
          echo "Waiting for 5 seconds to re-check node count. Current Ready node count is: ${CURRENT_READY_NODE_COUNT}"
          sleep 5
          CURRENT_READY_NODE_COUNT=$(kubectl get nodes | awk '{ print $2 }' | grep -E '(^|\s)Ready($|\s)' | wc -l)
        done
done || exit 1

kubectl get nodes

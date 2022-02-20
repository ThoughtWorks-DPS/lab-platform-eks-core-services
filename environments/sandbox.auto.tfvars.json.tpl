{
    "aws_region": "us-east-2",
    "assume_role": "DPSTerraformRole",
    "account_id": "{{ twdps/di/svc/aws/dps-2/aws-account-id }}",

    "cluster_name": "sandbox",
    "cluster_autoscaler_version": "1.21.2",
    "metrics_server_version": "0.6.1",
    "kube_state_metrics_version": "2.3.0",
    "aws_efs_csi_driver_version": "1.3.6",
    "aws_efs_csi_provisionser_version": "2.1.1",
    "aws_eks_liveness_probe_version": "2.4.0",
    "aws_efs_csi_node_driver_registrar": "2.1.0",
    "datadog_api_key": "{{ twdps/di/svc/datadog/api-key }}",
    "datadog_app_key": "{{ twdps/di/svc/datadog/app-key }}",
    "datadog_cluster_agent_version": "1.17.0",
    "datadog_agent_version": "7.33.0"
}

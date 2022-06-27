{
    "aws_region": "us-east-2",
    "aws_assume_role": "DPSPlatformEksBaseRole",
    "aws_account_id": "{{ op://empc-lab/aws-dps-2/aws-account-id }}",

    "cluster_name": "sandbox-us-east-2",

    "cluster_autoscaler_version": "v1.22.2",
    "metrics_server_version": "v0.6.1",
    "kube_state_metrics_chart_version": "4.9.2",
    "aws_efs_csi_driver_chart_version": "2.2.7",
    "alert_channel": "sandbox",

    "datadog_api_key": "{{ op://empc-lab/svc-datadog/api-key }}",
    "datadog_app_key": "{{ op://empc-lab/svc-datadog/app-key }}",
    "datadog_cluster_agent_version": "1.20.0",
    "datadog_agent_version": "7.37.0"
}

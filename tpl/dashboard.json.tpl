{
  "title": "EMPC lab-platform-eks-core-services",
  "description": "[lab-platform-eks-core-services](https://github.com/ThoughtWorks-DPS/lab-platform-eks-core-services)",
  "widgets": [
    {
      "definition": {
        "title": "Monitor Summary",
        "title_size": "13",
        "title_align": "left",
        "type": "manage_status",
        "summary_type": "monitors",
        "display_format": "countsAndList",
        "color_preference": "text",
        "hide_zero_counts": true,
        "show_last_triggered": false,
        "show_priority": false,
        "query": "tag:pipeline:lab-platform-eks-core-services",
        "sort": "status,asc",
        "count": 50,
        "start": 0
      },
      "layout": {
        "x": 0,
        "y": 0,
        "width": 3,
        "height": 6
      }
    },
    {
      "definition": {
        "type": "note",
        "content": "Dependencies",
        "background_color": "gray",
        "font_size": "18",
        "text_align": "center",
        "vertical_align": "center",
        "show_tick": false,
        "tick_pos": "50%",
        "tick_edge": "left",
        "has_padding": true
      },
      "layout": {
        "x": 3,
        "y": 0,
        "width": 8,
        "height": 1
      }
    },
    {

      "definition": {
        "type": "note",
        "content": "CURRENT_TABLE",
        "background_color": "yellow",
        "font_size": "14",
        "text_align": "left",
        "vertical_align": "top",
        "show_tick": true,
        "tick_pos": "50%",
        "tick_edge": "left",
        "has_padding": true
      },
      "layout": {
        "x": 3,
        "y": 1,
        "width": 6,
        "height": 3
      }
    },
    {
      "definition": {
        "type": "note",
        "content": "LATEST_TABLE",
        "background_color": "TABLE_COLOR",
        "font_size": "14",
        "text_align": "left",
        "vertical_align": "top",
        "show_tick": true,
        "tick_pos": "50%",
        "tick_edge": "left",
        "has_padding": true
      },
      "layout": {
        "x": 9,
        "y": 1,
        "width": 2,
        "height": 3
      }
    },
    {
      "definition": {
        "title": "core-services pod restarts",
        "title_size": "16",
        "title_align": "left",
        "show_legend": true,
        "legend_layout": "auto",
        "legend_columns": [
          "avg",
          "min",
          "max",
          "value",
          "sum"
        ],
        "type": "timeseries",
        "requests": [
          {
            "formulas": [
              {
                "formula": "query1"
              },
              {
                "formula": "query2"
              },
              {
                "formula": "query3"
              },
              {
                "formula": "query4"
              },
              {
                "formula": "query5"
              },
              {
                "formula": "query6"
              },
              {
                "formula": "query7"
              }
            ],
            "response_format": "timeseries",
            "queries": [
              {
                "query": "sum:kubernetes.containers.restarts{$cluster,kube_deployment:metrics-server}",
                "data_source": "metrics",
                "name": "query1"
              },
              {
                "query": "sum:kubernetes.containers.restarts{$cluster,kube_deployment:kube-state-metrics}",
                "data_source": "metrics",
                "name": "query2"
              },
              {
                "query": "sum:kubernetes.containers.restarts{$cluster,kube_deployment:cluster-autoscaler}",
                "data_source": "metrics",
                "name": "query3"
              },
              {
                "query": "sum:kubernetes.containers.restarts{$cluster,kube_deployment:efs-csi-controller}",
                "data_source": "metrics",
                "name": "query4"
              },
              {
                "query": "sum:kubernetes.containers.restarts{$cluster,kube_deployment:datadog-agent-cluster-agent}",
                "data_source": "metrics",
                "name": "query5"
              },
              {
                "query": "sum:kubernetes.containers.restarts{$cluster,kube_daemon_set:datadog-agent}",
                "data_source": "metrics",
                "name": "query6"
              },
              {
                "query": "sum:kubernetes.containers.restarts{$cluster,kube_daemon_set:efs-csi-node}",
                "data_source": "metrics",
                "name": "query7"
              }
            ],
            "style": {
              "palette": "dog_classic",
              "line_type": "solid",
              "line_width": "normal"
            },
            "display_type": "line"
          }
        ],
        "events": [
          {
            "q": "tags:cluster:$cluster, deployment:lab*"
          }
        ]
      },
      "layout": {
        "x": 3,
        "y": 4,
        "width": 8,
        "height": 2
      }
    },
    {
      "definition": {
        "type": "note",
        "content": "core services status",
        "background_color": "gray",
        "font_size": "18",
        "text_align": "center",
        "vertical_align": "center",
        "show_tick": false,
        "tick_pos": "50%",
        "tick_edge": "left",
        "has_padding": true
      },
      "layout": {
        "x": 0,
        "y": 6,
        "width": 11,
        "height": 1
      }
    },
    {
      "definition": {
        "title": "efs storage",
        "title_size": "16",
        "title_align": "left",
        "type": "query_value",
        "requests": [
          {
            "formulas": [
              {
                "formula": "query1"
              }
            ],
            "response_format": "scalar",
            "queries": [
              {
                "query": "avg:aws.efs.storage_bytes{$filesystemid}",
                "data_source": "metrics",
                "name": "query1",
                "aggregator": "avg"
              }
            ]
          }
        ],
        "autoscale": true,
        "precision": 0
      },
      "layout": {
        "x": 0,
        "y": 7,
        "width": 1,
        "height": 1
      }
    },
    {
      "definition": {
        "title": "efs i/o limit",
        "title_size": "16",
        "title_align": "left",
        "type": "query_value",
        "requests": [
          {
            "formulas": [
              {
                "formula": "query1"
              }
            ],
            "response_format": "scalar",
            "queries": [
              {
                "query": "avg:aws.efs.percent_iolimit{$filesystemid}",
                "data_source": "metrics",
                "name": "query1",
                "aggregator": "avg"
              }
            ]
          }
        ],
        "autoscale": true,
        "precision": 1
      },
      "layout": {
        "x": 1,
        "y": 7,
        "width": 1,
        "height": 1
      }
    },
    {
      "definition": {
        "title": "connections",
        "title_size": "16",
        "title_align": "left",
        "type": "query_value",
        "requests": [
          {
            "formulas": [
              {
                "formula": "query1"
              }
            ],
            "response_format": "scalar",
            "queries": [
              {
                "query": "avg:aws.efs.client_connections{$filesystemid}.as_count()",
                "data_source": "metrics",
                "name": "query1",
                "aggregator": "last"
              }
            ]
          }
        ],
        "autoscale": true,
        "precision": 2
      },
      "layout": {
        "x": 2,
        "y": 7,
        "width": 1,
        "height": 1
      }
    },
    {
      "definition": {
        "title": "Datadog Cluster Agent api requests",
        "title_size": "16",
        "title_align": "left",
        "show_legend": true,
        "legend_layout": "auto",
        "legend_columns": [
          "avg",
          "min",
          "max",
          "value",
          "sum"
        ],
        "type": "timeseries",
        "requests": [
          {
            "formulas": [
              {
                "formula": "query1"
              }
            ],
            "response_format": "timeseries",
            "queries": [
              {
                "query": "sum:datadog.cluster_agent.api_requests{$cluster}.as_count()",
                "data_source": "metrics",
                "name": "query1"
              }
            ],
            "style": {
              "palette": "dog_classic",
              "line_type": "solid",
              "line_width": "normal"
            },
            "display_type": "bars"
          }
        ]
      },
      "layout": {
        "x": 3,
        "y": 7,
        "width": 4,
        "height": 2
      }
    },
    {
      "definition": {
        "type": "note",
        "content": "Insert tracking of autoscaler scale up and down events",
        "background_color": "white",
        "font_size": "14",
        "text_align": "left",
        "vertical_align": "top",
        "show_tick": false,
        "tick_pos": "50%",
        "tick_edge": "left",
        "has_padding": true
      },
      "layout": {
        "x": 7,
        "y": 7,
        "width": 4,
        "height": 2
      }
    }
  ],
  "template_variables": [
    {
      "name": "cluster",
      "default": "sandbox",
      "prefix": "cluster",
      "available_values": []
    },
    {
      "name": "node",
      "default": "*",
      "prefix": "node",
      "available_values": []
    },
    {
      "name": "filesystemid",
      "default": "*",
      "prefix": "filesystemid",
      "available_values": []
    }
  ],
  "layout_type": "ordered",
  "is_read_only": false,
  "notify_list": [],
  "reflow_type": "fixed",
  "id": "t3v-8yp-k86"
}

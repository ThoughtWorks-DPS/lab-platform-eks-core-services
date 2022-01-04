#!/usr/bin/env bash
export CLUSTER=$1
export METRICS_SERVER_VERSION=$(cat $CLUSTER.auto.tfvars.json | jq -r .metrics_server_version)

cat <<EOF > metrics-server/apiservice.yaml
---
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  name: v1beta1.metrics.k8s.io
  namespace: kube-system
  labels:
    app: metrics-server
    version: "$METRICS_SERVER_VERSION"
    app.kubernetes.io/name: metrics-server
    app.kubernetes.io/instance: metrics-server
    app.kubernetes.io/version: "$METRICS_SERVER_VERSION"
spec:
  group: metrics.k8s.io
  groupPriorityMinimum: 100
  insecureSkipTLSVerify: true
  service:
    name: metrics-server
    namespace: kube-system
  version: v1beta1
  versionPriority: 100
EOF

cat <<EOF > metrics-server/deployment.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: metrics-server
  namespace: kube-system
  labels:
    app: metrics-server
    version: "$METRICS_SERVER_VERSION"
    app.kubernetes.io/name: metrics-server
    app.kubernetes.io/instance: metrics-server
    app.kubernetes.io/version: "$METRICS_SERVER_VERSION"
spec:
  replicas: 2
  strategy:
    rollingUpdate:
      maxUnavailable: 1
    type: RollingUpdate
  selector:
    matchLabels:
      app.kubernetes.io/name: metrics-server
      app.kubernetes.io/instance: metrics-server
  template:
    metadata:
      labels:
        app.kubernetes.io/name: metrics-server
        app.kubernetes.io/instance: metrics-server
    spec:
      serviceAccountName: metrics-server
      priorityClassName: "system-cluster-critical"
      containers:
        - name: metrics-server
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            runAsNonRoot: true
            runAsUser: 1000
          image: k8s.gcr.io/metrics-server/metrics-server:v$METRICS_SERVER_VERSION
          imagePullPolicy: IfNotPresent
          args:
            - --secure-port=4443
            - --cert-dir=/tmp
            - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
            - --kubelet-use-node-status-port
            - --metric-resolution=15s
          ports:
          - name: https
            protocol: TCP
            containerPort: 4443
          livenessProbe:
            failureThreshold: 3
            httpGet:
              path: /livez
              port: https
              scheme: HTTPS
            initialDelaySeconds: 0
            periodSeconds: 10
          readinessProbe:
            failureThreshold: 3
            httpGet:
              path: /readyz
              port: https
              scheme: HTTPS
            initialDelaySeconds: 20
            periodSeconds: 10
          volumeMounts:
            - name: tmp
              mountPath: /tmp
      volumes:
        - name: tmp
          emptyDir: {}
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels:
                k8s-app: metrics-server
            namespaces:
            - kube-system
            topologyKey: kubernetes.io/hostname
EOF

cat <<EOF > metrics-server/pod-disruption-budget.yaml
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: metrics-server
  namespace: kube-system
  labels:
    app: metrics-server
    version: "$METRICS_SERVER_VERSION"
    app.kubernetes.io/name: metrics-server
    app.kubernetes.io/instance: metrics-server
    app.kubernetes.io/version: "$METRICS_SERVER_VERSION"
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: metrics-server
      app.kubernetes.io/instance: metrics-server
EOF

cat <<EOF > metrics-server/rbac.yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: system:metrics-server-aggregated-reader
  labels:
    app: metrics-server
    version: "$METRICS_SERVER_VERSION"
    app.kubernetes.io/name: metrics-server
    app.kubernetes.io/instance: metrics-server
    app.kubernetes.io/version: "$METRICS_SERVER_VERSION"
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
rules:
  - apiGroups:
      - metrics.k8s.io
    resources:
      - pods
      - nodes
    verbs:
      - get
      - list
      - watch

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: system:metrics-server
  labels:
    app: metrics-server
    version: "$METRICS_SERVER_VERSION"
    app.kubernetes.io/name: metrics-server
    app.kubernetes.io/instance: metrics-server
    app.kubernetes.io/version: "$METRICS_SERVER_VERSION"
rules:
  - apiGroups:
    - ""
    resources:
      - pods
      - nodes
      - nodes/stats
      - namespaces
      - configmaps
    verbs:
      - get
      - list
      - watch

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: metrics-server:system:auth-delegator
  labels:
    app: metrics-server
    version: "$METRICS_SERVER_VERSION"
    app.kubernetes.io/name: metrics-server
    app.kubernetes.io/instance: metrics-server
    app.kubernetes.io/version: "$METRICS_SERVER_VERSION"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
  - kind: ServiceAccount
    name: metrics-server
    namespace: kube-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:metrics-server
  labels:
    app: metrics-server
    version: "$METRICS_SERVER_VERSION"
    app.kubernetes.io/name: metrics-server
    app.kubernetes.io/instance: metrics-server
    app.kubernetes.io/version: "$METRICS_SERVER_VERSION"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:metrics-server
subjects:
  - kind: ServiceAccount
    name: metrics-server
    namespace: kube-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: metrics-server-auth-reader
  namespace: kube-system
  labels:
    app: metrics-server
    version: "$METRICS_SERVER_VERSION"
    app.kubernetes.io/name: metrics-server
    app.kubernetes.io/instance: metrics-server
    app.kubernetes.io/version: "$METRICS_SERVER_VERSION"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
  - kind: ServiceAccount
    name: metrics-server
    namespace: kube-system
EOF

cat <<EOF > metrics-server/serice-account.yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: metrics-server
  namespace: kube-system
  labels:
    app: metrics-server
    version: "$METRICS_SERVER_VERSION"
    app.kubernetes.io/name: metrics-server
    app.kubernetes.io/instance: metrics-server
    app.kubernetes.io/version: "$METRICS_SERVER_VERSION"
EOF

cat <<EOF > metrics-server/service.yaml
---
apiVersion: v1
kind: Service
metadata:
  name: metrics-server
  namespace: kube-system
  labels:
    app: metrics-server
    version: "$METRICS_SERVER_VERSION"
    app.kubernetes.io/name: metrics-server
    app.kubernetes.io/instance: metrics-server
    app.kubernetes.io/version: "$METRICS_SERVER_VERSION"
spec:
  type: ClusterIP
  ports:
    - name: https
      port: 443
      protocol: TCP
      targetPort: https
  selector:
    app.kubernetes.io/name: metrics-server
    app.kubernetes.io/instance: metrics-server
EOF

kubectl apply -f metrics-server/ --recursive

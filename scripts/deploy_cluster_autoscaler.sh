#!/usr/bin/env bash
export CLUSTER=$1
export CLUSTER_AUTOSCALER_VERSION=$(cat $CLUSTER.auto.tfvars.json | jq -r .cluster_autoscaler_version)
export ACCOUNT_ID=$(cat $CLUSTER.auto.tfvars.json | jq -r .account_id)
export AWS_REGION=$(cat $CLUSTER.auto.tfvars.json | jq -r .aws_region)

cat <<EOF > cluster-autoscaler/service-account.yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/instance: "$CLUSTER"
    app.kubernetes.io/name: "cluster-autoscaler"
    app.kubernetes.io/managed-by: "Helm"
    helm.sh/chart: "cluster-autoscaler-9.10.8"
  name: $CLUSTER-cluster-autoscaler
  namespace: kube-system
  annotations: 
    eks.amazonaws.com/role-arn: arn:aws:iam::090950721693:role/$CLUSTER-cluster-autoscaler
automountServiceAccountToken: true

---
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/instance: "$CLUSTER"
    app.kubernetes.io/name: "cluster-autoscaler"
    app.kubernetes.io/managed-by: "Helm"
    helm.sh/chart: "cluster-autoscaler-9.10.8"
  name: $CLUSTER-cluster-autoscaler
  namespace: kube-system
spec:
  ports:
    - port: 8085
      protocol: TCP
      targetPort: 8085
      name: http
  selector:
    app.kubernetes.io/instance: "$CLUSTER"
    app.kubernetes.io/name: "cluster-autoscaler"
  type: "ClusterIP"
EOF

cat <<EOF > cluster-autoscaler/rbac.yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/instance: "$CLUSTER"
    app.kubernetes.io/name: "cluster-autoscaler"
    app.kubernetes.io/managed-by: "Helm"
    helm.sh/chart: "cluster-autoscaler-9.10.8"
  name: $CLUSTER-cluster-autoscaler
rules:
  - apiGroups:
    - ""
    resources:
    - events
    - endpoints
    verbs:
    - create
    - patch
  - apiGroups:
    - ""
    resources:
    - pods/eviction
    verbs:
    - create
  - apiGroups:
    - ""
    resources:
    - pods/status
    verbs:
    - update
  - apiGroups:
    - ""
    resources:
    - endpoints
    resourceNames:
    - cluster-autoscaler
    verbs:
    - get
    - update
  - apiGroups:
    - ""
    resources:
    - nodes
    verbs:
    - watch
    - list
    - get
    - update
  - apiGroups:
    - ""
    resources:
    - namespaces
    - pods
    - services
    - replicationcontrollers
    - persistentvolumeclaims
    - persistentvolumes
    verbs:
    - watch
    - list
    - get
  - apiGroups:
    - batch
    resources:
    - jobs
    - cronjobs
    verbs:
    - watch
    - list
    - get
  - apiGroups:
    - batch
    - extensions
    resources:
    - jobs
    verbs:
    - get
    - list
    - patch
    - watch
  - apiGroups:
    - extensions
    resources:
    - replicasets
    - daemonsets
    verbs:
    - watch
    - list
    - get
  - apiGroups:
    - policy
    resources:
    - poddisruptionbudgets
    verbs:
    - watch
    - list
  - apiGroups:
    - apps
    resources:
    - daemonsets
    - replicasets
    - statefulsets
    verbs:
    - watch
    - list
    - get
  - apiGroups:
    - storage.k8s.io
    resources:
    - storageclasses
    - csinodes
    - csidrivers
    - csistoragecapacities
    verbs:
    - watch
    - list
    - get
  - apiGroups:
    - ""
    resources:
    - configmaps
    verbs:
    - list
    - watch
    - get
    - update
  - apiGroups:
    - coordination.k8s.io
    resources:
    - leases
    verbs:
    - create
  - apiGroups:
    - coordination.k8s.io
    resourceNames:
    - cluster-autoscaler
    resources:
    - leases
    verbs:
    - get
    - update

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app.kubernetes.io/instance: "$CLUSTER"
    app.kubernetes.io/name: "cluster-autoscaler"
    app.kubernetes.io/managed-by: "Helm"
    helm.sh/chart: "cluster-autoscaler-9.10.8"
  name: $CLUSTER-cluster-autoscaler
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: $CLUSTER-cluster-autoscaler
subjects:
  - kind: ServiceAccount
    name: $CLUSTER-cluster-autoscaler
    namespace: kube-system

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    app.kubernetes.io/instance: "$CLUSTER"
    app.kubernetes.io/name: "cluster-autoscaler"
    app.kubernetes.io/managed-by: "Helm"
    helm.sh/chart: "cluster-autoscaler-9.10.8"
  name: $CLUSTER-cluster-autoscaler
  namespace: kube-system
rules:
  - apiGroups:
    - ""
    resources:
    - configmaps
    verbs:
    - create
  - apiGroups:
    - ""
    resources:
    - configmaps
    resourceNames:
    - cluster-autoscaler-status
    verbs:
    - delete
    - get
    - update

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    app.kubernetes.io/instance: "$CLUSTER"
    app.kubernetes.io/name: "cluster-autoscaler"
    app.kubernetes.io/managed-by: "Helm"
    helm.sh/chart: "cluster-autoscaler-9.10.8"
  name: $CLUSTER-cluster-autoscaler
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: $CLUSTER-cluster-autoscaler
subjects:
  - kind: ServiceAccount
    name: $CLUSTER-cluster-autoscaler
    namespace: kube-system
EOF

cat <<EOF > cluster-autoscaler/deployment.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.kubernetes.io/instance: "$CLUSTER"
    app.kubernetes.io/name: "cluster-autoscaler"
    app.kubernetes.io/managed-by: "Helm"
    helm.sh/chart: "cluster-autoscaler-9.10.8"
  name: $CLUSTER-cluster-autoscaler
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/instance: "$CLUSTER"
      app.kubernetes.io/name: "cluster-autoscaler"
  template:
    metadata:
      annotations:
        cluster-autoscaler.kubernetes.io/safe-to-evict: "true"
      labels:
        app.kubernetes.io/instance: "$CLUSTER"
        app.kubernetes.io/name: "cluster-autoscaler"
    spec:
      dnsPolicy: "ClusterFirst"
      containers:
        - name: cluster-autoscaler
          image: "k8s.gcr.io/autoscaling/cluster-autoscaler:v$CLUSTER_AUTOSCALER_VERSION"
          imagePullPolicy: "Always"
          command:
            - ./cluster-autoscaler
            - --cloud-provider=aws
            - --namespace=kube-system
            - --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/$CLUSTER
            - --balance-similar-node-groups=true
            - --expander=least-waste
            - --logtostderr=true
            - --skip-nodes-with-local-storage=false
            - --skip-nodes-with-system-pods=false
            - --stderrthreshold=info
            - --v=4
          env:
            - name: AWS_REGION
              value: "$AWS_REGION"
          livenessProbe:
            httpGet:
              path: /health-check
              port: 8085
          ports:
            - containerPort: 8085
          resources:
            {}
      serviceAccountName: $CLUSTER-cluster-autoscaler
      tolerations:
        []

---
# Source: cluster-autoscaler/templates/pdb.yaml
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  labels:
    app.kubernetes.io/instance: "$CLUSTER"
    app.kubernetes.io/name: "cluster-autoscaler"
    app.kubernetes.io/managed-by: "Helm"
    helm.sh/chart: "cluster-autoscaler-9.10.8"
  name: $CLUSTER-cluster-autoscaler
spec:
  selector:
    matchLabels:
      app.kubernetes.io/instance: "$CLUSTER"
      app.kubernetes.io/name: "cluster-autoscaler"
  maxUnavailable: 1
EOF

# kubectl apply -f cluster-autoscaler --recursive

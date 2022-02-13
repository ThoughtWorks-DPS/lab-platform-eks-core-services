---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    app.kubernetes.io/name: aws-efs-csi-driver
  name: efs-csi-node
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: efs-csi-node
      app.kubernetes.io/instance: kustomize
      app.kubernetes.io/name: aws-efs-csi-driver
  template:
    metadata:
      labels:
        app: efs-csi-node
        app.kubernetes.io/instance: kustomize
        app.kubernetes.io/name: aws-efs-csi-driver
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: eks.amazonaws.com/compute-type
                operator: NotIn
                values:
                - fargate
      containers:
      - args:
        - --endpoint=$(CSI_ENDPOINT)
        - --logtostderr
        - --v=2
        env:
        - name: CSI_ENDPOINT
          value: unix:/csi/csi.sock
        image: 602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/aws-efs-csi-driver:vEFS_CSI_DRIVER_VERSION
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 5
          httpGet:
            path: /healthz
            port: healthz
          initialDelaySeconds: 10
          periodSeconds: 2
          timeoutSeconds: 3
        name: efs-plugin
        ports:
        - containerPort: 9809
          name: healthz
          protocol: TCP
        securityContext:
          privileged: true
        volumeMounts:
        - mountPath: /var/lib/kubelet
          mountPropagation: Bidirectional
          name: kubelet-dir
        - mountPath: /csi
          name: plugin-dir
        - mountPath: /var/run/efs
          name: efs-state-dir
        - mountPath: /var/amazon/efs
          name: efs-utils-config
        - mountPath: /etc/amazon/efs-legacy
          name: efs-utils-config-legacy
      - args:
        - --csi-address=$(ADDRESS)
        - --kubelet-registration-path=$(DRIVER_REG_SOCK_PATH)
        - --v=2
        env:
        - name: ADDRESS
          value: /csi/csi.sock
        - name: DRIVER_REG_SOCK_PATH
          value: /var/lib/kubelet/plugins/efs.csi.aws.com/csi.sock
        - name: KUBE_NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        image: 602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/csi-node-driver-registrar:vCSI_NODE_DRIVER_REGISTRAR
        imagePullPolicy: IfNotPresent
        name: csi-driver-registrar
        volumeMounts:
        - mountPath: /csi
          name: plugin-dir
        - mountPath: /registration
          name: registration-dir
      - args:
        - --csi-address=/csi/csi.sock
        - --health-port=9809
        - --v=2
        image: 602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/livenessprobe:vLIVENESS_PROBE_VERSION
        imagePullPolicy: IfNotPresent
        name: liveness-probe
        volumeMounts:
        - mountPath: /csi
          name: plugin-dir
      dnsPolicy: ClusterFirst
      hostNetwork: true
      nodeSelector:
        beta.kubernetes.io/os: linux
      priorityClassName: system-node-critical
      serviceAccountName: efs-csi-node-sa
      tolerations:
      - operator: Exists
      volumes:
      - hostPath:
          path: /var/lib/kubelet
          type: Directory
        name: kubelet-dir
      - hostPath:
          path: /var/lib/kubelet/plugins/efs.csi.aws.com/
          type: DirectoryOrCreate
        name: plugin-dir
      - hostPath:
          path: /var/lib/kubelet/plugins_registry/
          type: Directory
        name: registration-dir
      - hostPath:
          path: /var/run/efs
          type: DirectoryOrCreate
        name: efs-state-dir
      - hostPath:
          path: /var/amazon/efs
          type: DirectoryOrCreate
        name: efs-utils-config
      - hostPath:
          path: /etc/amazon/efs
          type: DirectoryOrCreate
        name: efs-utils-config-legacy
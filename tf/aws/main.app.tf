resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
  depends_on = [module.eks_cluster.node_group_ids]
}

resource "kubectl_manifest" "docker_secret" {
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: ghcr-secret
  namespace: ${kubernetes_namespace.namespace.metadata[0].name}
data:
  .dockerconfigjson: ${base64encode("{\"auths\":{\"ghcr.io\":{\"username\":\"${var.docker_username}\",\"password\":\"${var.docker_password}\",\"email\":\"${var.docker_email}\"}}}")}
type: kubernetes.io/dockerconfigjson
YAML
}

resource "kubectl_manifest" "docplanner_go_deployment" {
  yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: docplanner-go
  namespace: poc
  labels:
    app: docplanner-go
spec:
  replicas: 1
  selector:
    matchLabels:
      app: docplanner-go
  template:
    metadata:
      labels:
        app: docplanner-go
    spec:
      imagePullSecrets:
      - name: ghcr-secret
      containers:
      - name: go-app
        image: ghcr.io/magnonta/golang-poc
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
        startupProbe:
          httpGet:
            path: /
            port: 8080
          failureThreshold: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "256Mi"
YAML
}

resource "kubectl_manifest" "docplanner_php_deployment" {
  yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: docplanner-php
  namespace: poc
  labels:
    app: docplanner-php
spec:
  replicas: 1
  selector:
    matchLabels:
      app: docplanner-php
  template:
    metadata:
      labels:
        app: docplanner-php
    spec:
      imagePullSecrets:
      - name: ghcr-secret
      containers:
      - name: php-app
        image: ghcr.io/magnonta/php-poc:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 80
        startupProbe:
          httpGet:
            path: /
            port: 80
          failureThreshold: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 10
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "256Mi"
YAML
}

resource "kubectl_manifest" "docplanner_service_go" {
  yaml_body = <<YAML
apiVersion: v1
kind: Service
metadata:
  name: docplanner-service-go
  namespace: poc
  labels: 
    app: docplanner-go
spec:
  selector:
    app: docplanner-go
  type: ClusterIP
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
      name: go-app
YAML
}

resource "kubectl_manifest" "docplanner_service_php" {
  yaml_body = <<YAML
apiVersion: v1
kind: Service
metadata:
  name: docplanner-service-php
  namespace: poc
spec:
  selector:
    app: docplanner-php
  type: ClusterIP
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      name: php-app
YAML
}

resource "kubectl_manifest" "docplanner_ingress" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: docplanner-ingress
  namespace: poc
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  ingressClassName: nginx
  rules:
    - http:
        paths:
          - path: /api/v1/
            pathType: Prefix
            backend:
              service:
                name: docplanner-service-go
                port:
                  number: 80
          - path: /api/v2/
            pathType: Prefix
            backend:
              service:
                name: docplanner-service-php
                port:
                  number: 80
YAML
}

resource "kubectl_manifest" "docplanner_hpa" {
  yaml_body = <<YAML
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: docplanner-hpa
  namespace: poc
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: docplanner
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 10
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 10
YAML
}

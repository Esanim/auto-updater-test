import manifests
import secrets
import app

kubernetesRender = lambda a: app.App {
    deployment = {
        apiVersion = "apps/v1"
        kind = "Deployment"
        metadata.name = a.name
        metadata.labels = a.labels
        spec = {
            replicas = a.replicas
            revisionHistoryLimit = a.revisionHistoryLimit
            selector.matchLabels = a.labels
            template.metadata.labels = a.labels
            template.spec.securityContext = a.securityContext
            template.spec.serviceAccountName = a.serviceAccountName
            template.spec.volumes = a.volumes
            template.spec.containers = [
                {
                    name = n
                    image = c.image
                    imagePullPolicy = c.imagePullPolicy
                    command = c.command
                    args = c.args
                    env = c.env
                    envFrom = c.envFrom
                    volumeMounts = c.volumeMounts
                    resources: c.resources
                    ports = c.ports
                    startupProbe: c.startupProbe
                    livenessProbe: c.livenessProbe
                    readinessProbe: c.readinessProbe
                } for n, c in a.containers
            ]
        }
    }

    service = {
        apiVersion = "v1"
        kind = "Service"
        metadata.name = a.name
        metadata.labels = a.labels
        metadata.annotations = a.service?.annotations
        spec = {
            clusterIP = a.service?.clusterIP
            type = a.service?.$type
            selector = a.labels
            ports = a.service?.ports
        }
    }

    secrets = [{
        apiVersion = "external-secrets.io/v1beta1"
        kind = "ExternalSecret"
        metadata = secrets.Metadata {
            name = n.name
        }
        spec = secrets.Spec {
            target = {
                name = n.data.targetName
            }
            data = [{
                secretKey = n.data.secretKey
                remoteRef = {
                    key = n.data.remoteRefKey
                }
            }]
        }
    } for n in a.secrets]

    service_account = {
        apiVersion: "v1"
        kind: "ServiceAccount"
        metadata.name = a.name
        metadata.labels = a.labels
        metadata.annotations = a.service_account_annotations
    }

    hpa = {
        apiVersion: "autoscaling/v2"
        kind: "HorizontalPodAutoscaler"
        metadata.name = a.name
        metadata.labels = a.labels
        metadata.annotations = a.hpa?.annotations
        spec = {
            scaleTargetRef: {
                apiVersion: "apps/v1"
                kind: "Deployment"
                name: a.name
            }
            minReplicas: a.hpa?.minReplicas
            maxReplicas: a.hpa?.maxReplicas
            metrics: a.hpa?.metrics
        }
    }

    pdb = {
        apiVersion: "policy/v1beta1"
        kind: "PodDisruptionBudget"
        metadata.name = a.name
        metadata.labels = a.labels
        metadata.annotations = a.pdb?.annotations
        spec = {
            minAvailable: a.pdb?.minAvailable
              selector = {
                  matchLabels = {
                    "app.kubernetes.io/instance": a.name
                  }
              }
        }
    }

    [
        deployment,
        service_account,
        if a.pdb: pdb,
        if a.hpa: hpa,
        if a.service: service,
        if a.secrets: secrets
    ]
}

manifests.yaml_stream(sum([kubernetesRender(a) for a in app.App.instances()], []))

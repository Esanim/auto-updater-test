schema App:
    """The application model."""
    name: str
    replicas: int = 1
    labels?: {str:str} = {app = name}
    service?: Service
    containers?: {str: Container}
    service_account_annotations?: {str:str} = {}
    secrets?: any
    pdb?: PodDisruptionBudget
    hpa?: HorizontalPodAutoscaler
    annotations?: {str:str} = {}
    revisionHistoryLimit?: int = 10
    securityContext?: SecurityContext
    volumes?: [Volume]
    serviceAccountName: str

schema Volume:
    """Volume"""
    name: str
    hostPath?: PathRef
    secret?: SecretNameRef

schema SecurityContext:
    """SecurityContext"""
    runAsUser?: int
    runAsGroup?: int
    fsGroup?: int
    runAsNonRoot?: bool = False
    readOnlyRootFilesystem?: bool = False
    allowPrivilegeEscalation?: bool = False
    capabilities?: Capabilities

schema Capabilities:
    """Capabilities"""
    add?: [str]
    drop?: [str]

schema HorizontalPodAutoscaler:
    """HorizontalPodAutoscaler"""
    minReplicas: int
    maxReplicas: int
    annotations?: {str:str} = {}
    metrics?: [Metric]

schema Metric:
    """Metric"""
    type: "Resource" | "Object" | "External"
    resource?: str
    object?: str
    external?: str

schema PodDisruptionBudget:
    """PodDisruptionBudget"""
    minAvailable?: int
    annotations?: {str:str} = {}

schema Service:
    """The service model."""
    $type?: str
    ports: [Port]
    clusterIP?: str
    annotations?: {str:str} = {}

schema Port:
    """The port model."""
    port: int
    protocol: "TCP" | "UDP" | "SCTP" = "TCP"
    targetPort?: int | str

schema Container:
    """The container model."""
    image: str
    imagePullPolicy?: "Always" | "Never" | "IfNotPresent" = "IfNotPresent"
    command?: [str]
    args?: [str]
    env?: [Env]
    envFrom?: [EnvFrom]
    volumeMounts?: [VolumeMount]
    resources?: Resource
    ports: [ContainerPort]
    startupProbe?: Probe
    livenessProbe?: Probe
    readinessProbe?: Probe

schema Probe:
    """The probe model."""
    failureThreshold?: int
    httpGet?: HttpGet
    initialDelaySeconds?: int
    periodSeconds?: int
    successThreshold?: int
    timeoutSeconds?: int

schema HttpGet:
    """The HTTP GET model."""
    path: str
    port: int
    scheme: "HTTP" | "HTTPS" = "HTTP"
    
schema ContainerPort:
    """The container port model."""
    name?: str
    protocol: "TCP" | "UDP" | "SCTP" = "TCP"
    containerPort: int

    check:
        1 <= containerPort <= 65535, "containerPort must be between 1 and 65535, inclusive"

schema Env:
    name: str
    value: str

schema EnvFrom:
    configMapRef?: NameRef
    secretRef?: NameRef

schema NameRef:
    name: str

schema PathRef:
    path: str

schema SecretNameRef:
    secretName: str

schema VolumeMount:
    source: str
    path: str
    target: str
    readOnly?: bool = False

schema Resource:
    limits?: {str:}
    requests?: {str:}

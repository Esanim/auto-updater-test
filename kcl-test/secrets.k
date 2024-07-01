schema Metadata:
    name: str
    annotations = {"argocd.argoproj.io/sync-wave": "0"}
    namespace = "lukso"

schema SpecTarget:
    name: str
    creationPolicy = "Owner"

schema RemoteRef:
    key: str
    version = "latest"

schema SpecData:
    secretKey: str
    remoteRef: RemoteRef

schema Spec:
    secretStoreRef = {
        kind = "ClusterSecretStore"
        name = "main"
    }
    target: SpecTarget
    data: [SpecData]

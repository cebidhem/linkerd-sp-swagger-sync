# linkerd-sp-swagger-sync

Applying Linkerd ServiceProfiles generated from Swagger automatically

### Goal

Linkerd allows to create ServiceProfiles from a Swagger file. This is great when you can generate it locally, or include it somehow in your deployments (Helm, Flux, etc...)

In my case, I want to reconfigure the ServiceProfile of my backends each time I deploy it in Kubernetes, without wondering if my routes have been updated this time or not. Obviously, several version live at the same time in different clusters, I just don't want to track that.

This docker image aims at getting a Swagger documentation online, process it with linkerd commands to generate the ServiceProfile and apply it in cluster.

In my case, I'll run it as a Helm post-upgrade hook.

### Non Goals

This fulfills a very specific use-case and yours may be different. If your contributions are welcomed, please note that this is a side project that I'll maintain on my free time on a best effort basis. 

Of course, feel also free to fork the project: it's under the [MIT license](LICENSE).

### Examples

This can be run as a [job](#job-definition) (e.g as a Helm post-upgrade hook). 

If you intend to run this way as well, be aware that you must configure RBAC (either [cluster scoped](#cluster-scoped-rbac) or [namespaced](#namespaced-rbac)) with your job.

#### Job definition

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: linkerd-serviceprofile-update-job
  namespace: my_app
  annotations:
    "helm.sh/hook": post-install,post-upgrade
    "helm.sh/hook-delete-policy": before-hook-creation
spec:
  template:
    spec:
      serviceAccountName: linkerd-serviceprofile-update
      containers:
        - name: sp-sync
          image: "ghcr.io/cebidhem/linkerd-sp-swagger-sync:latest"
          args:
            - URL_TO_JSON_SWAGGER_DEFINITION_FILE
            - SERVICE_NAME
      restartPolicy: OnFailure
```

#### Cluster scoped RBAC

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: linkerd-serviceprofile-update
rules:
  - apiGroups:
      - ""
    resources:
    - configmaps
    verbs:
    - get
  - apiGroups:
      - linkerd.io
    resources:
      - serviceprofiles
    verbs:
      - create
      - get
      - patch
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: linkerd-serviceprofile-update
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: linkerd-serviceprofile-update
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: linkerd-serviceprofile-update
subjects:
  - kind: ServiceAccount
    name: linkerd-serviceprofile-update
```

#### Namespaced RBAC

* **In your application namespace**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: linkerd-serviceprofile-update
  namespace: my_app
rules:
  - apiGroups:
      - linkerd.io
    resources:
      - serviceprofiles
    verbs:
      - create
      - get
      - patch
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: linkerd-serviceprofile-update
  namespace: my_app
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: linkerd-serviceprofile-update
  namespace: my_app
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: linkerd-serviceprofile-update
subjects:
  - kind: ServiceAccount
    name: linkerd-serviceprofile-update
    namespace: my_app
```

* **In Linkerd namespace**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: linkerd-serviceprofile-update
  namespace: linkerd
rules:
  - apiGroups:
      - ""
    resources:
      - configmaps
    verbs:
      - get
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: linkerd-serviceprofile-update
  namespace: linkerd
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: linkerd-serviceprofile-update
subjects:
  - kind: ServiceAccount
    name: linkerd-serviceprofile-update
    namespace: my_app
```

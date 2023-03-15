# Deployment Instructions

```bash 
oc new-project istio-system
```

#### Only for IBM Cloud

```bash 
oc get secret all-icr-io -n default -o yaml | sed 's/default/istio-system/g' | oc create -n istio-system -f -
```

#### Deploy the Control Plane

```bash 
cd maistra-2.1/mesh/mesh-control-plane
export SMCP_NS=istio-system
helm install mesh-control-plane -n $SMCP_NS .
```

### Wait for the resources in the istio-system namespace until they are ready

```bash 
watch 'oc describe smcp -n $SMCP_NS | tail'
```

Look for the `Ready` event at the bottom of the event list:
```
[root@jumpserver mesh-control-plane]# oc describe smcp -n istio-system | tail
  Normal  Installing      20m                servicemeshcontrolplane-controller  Installing mesh generation 2
  Normal  PausingInstall  20m (x2 over 20m)  servicemeshcontrolplane-controller  Paused until the following components become ready: [istio-discovery]
  Normal  PausingInstall  20m (x6 over 20m)  servicemeshcontrolplane-controller  Paused until the following components become ready: [prometheus]
  Normal  PausingInstall  20m (x2 over 20m)  servicemeshcontrolplane-controller  Paused until the following components become ready: [grafana istio-egress istio-ingress]
  Normal  PausingInstall  19m (x2 over 19m)  servicemeshcontrolplane-controller  Paused until the following components become ready: [istio-egress istio-ingress]
  Normal  PausingInstall  19m                servicemeshcontrolplane-controller  Paused until the following components become ready: [istio-egress]
  Normal  PausingInstall  19m (x2 over 19m)  servicemeshcontrolplane-controller  Paused until the following components become ready: [wasm-extensions]
  Normal  Pruning         19m                servicemeshcontrolplane-controller  Pruning obsolete resources
  Normal  Installed       19m                servicemeshcontrolplane-controller  Successfully installed version 2.1.0-0.el8-2
  Normal  Ready           19m                servicemeshcontrolplane-controller  All component deployments are Available
```

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
helm install mesh-control-plane -n istio-system .
```

### Wait for the resources in the istio-system namespace until they are ready

```bash 
watch 'oc describe smcp -n istio-system | tail'
```

# Deployment Instructions 

```bash 
oc new-project istio-operator
```

#### Only for IBM Cloud

```bash 
oc get secret all-icr-io -n default -o yaml | sed 's/default/istio-operator/g' | oc create -n istio-operator -f -
```

#### Deploy the operator

```bash 
helm install mesh-operator -n istio-operator .
```

### Wait for the resources in the istio-operator namespace until they are ready

```bash 
watch 'kubectl get pods -n istio-operator'
```
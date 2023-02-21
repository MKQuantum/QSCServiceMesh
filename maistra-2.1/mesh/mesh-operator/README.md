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
cd maistra-2.1/mesh/mesh-operator
helm install mesh-operator -n istio-operator .
```

### Wait for the resources in the istio-operator namespace until they are ready

```bash 
watch 'oc get pods -n istio-operator'
```

You should see something like this:
```
Every 2.0s: oc get pods -n istio-operator                                                                                                                    Tue Feb 21 11:04:40 2023

NAME                              READY   STATUS    RESTARTS   AGE
istio-operator-54cf84c65b-sthhx   1/1     Running   0          3m42s
```

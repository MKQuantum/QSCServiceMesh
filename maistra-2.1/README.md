# Deployment instructions for service Mesh

Disclaimer: This is a test setup and not ready for production deployment

### 1) Deploy Elastic search, Jaeger, and Kiali operator 
```bash 
oc apply -n openshift-operators -f mesh/dependant-operator.yaml
```

### 2) Deploy the operator and smcp
 - Deploy the mesh-operator first (follow instructions in the readme under the `mesh-operator` directory [here](mesh/mesh-operator/README.md) )
 - Then deploy the mesh-control-plane (follow instructions in the readme under the `mesh-control-plane` directory [here](mesh/mesh-control-plane/README.md))
   
### 3) Deploy the bookinfo application
 - Follow the instruction [here](bookinfo/README.md) to deploy the bookinfo app

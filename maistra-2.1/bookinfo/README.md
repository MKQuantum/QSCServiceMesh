# Deployment Instructions
We'll start with plain HTTP, and improve the security posture incrementally to Q-Safe.

The security levels we'll go through are the following -
1. Legacy TLS connection from outside the cluster, plain HTTP connection for communication within the cluster
2. Legacy TLS connection from outside the cluster, legacy strict mTLS connection for communication within the cluster
3. Legacy TLS connection from outside the cluster, Q-Safe strict mTLS connection for communication within the cluster
4. Q-Safe TLS connection from outside the cluster, Q-Safe strict mTLS connection for communication within the cluster

After completing all the steps., we'd have enabled complete Q-Safe protection for network communication into and within the cluster.

## 1) Legacy HTTPS to Ingress and HTTP connection Intra-Cluster
- Prerequisite : Make sure that the gateway certs are generated and uploaded as a secret 
```bash 
./generate-certs.sh

# Do the following only for IBM Cloud
oc get secret all-icr-io -n default -o yaml | sed 's/default/test/g' | oc create -n test -f -
```

- Install the bookinfo app
``` bash 
helm install bookinfo -n test .
```

### Prerequisite to validate traffic flow (install krew, ksniff, and wireshark)

- krew
  ```bash
  (
    set -x; cd "$(mktemp -d)" &&
    OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
    KREW="krew-${OS}_${ARCH}" &&
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
    tar zxvf "${KREW}.tar.gz" &&
    ./"${KREW}" install krew
  )
  ```
  - Follow the instructions to add `krew` installation directory to your path
  
- ksniff
  ``` bash
  kubectl krew install sniff
  ```
- wireshark (instructions for ubuntu)
  ``` bash
  sudo add-apt-repository ppa:wireshark-dev/stable
  sudo apt-get update
  sudo apt-get install wireshark
  ```
  - Configure wireshark to sniff without root
  ``` bash 
  sudo dpkg-reconfigure wireshark-common
  sudo chmod +x /usr/bin/dumpcap
  ```

### Validate HTTP traffic flow between the Ingress Gateway and Product page (Intra-cluster)
``` bash
INGRESS_GATEWAY=$(kubectl get pods -n istio-system | grep ingress | awk '{print $1}')
kubectl sniff -p ${INGRESS_GATEWAY} -n istio-system -i eth0 2>/dev/null &
INGRESS_GATEWAY_IP=$(kubectl get pods -o wide -n istio-system | grep ingress | awk '{print $6}')
PRODUCT_PAGE_IP=$(kubectl get pods -o wide -n test | grep productpage-v1 | awk '{print $6}')
echo -e "Use the following filter in wireshark: \n ip.src == ${INGRESS_GATEWAY_IP} and ip.dst == ${PRODUCT_PAGE_IP} \n"
```

- Intiate 10 requests to the bookinfo application
``` bash 
export GATEWAY_URL=$(kubectl get route istio-ingressgateway -n istio-system -o=jsonpath="{.spec.host}")
for i in `seq 1 10`; do  docker run --net host --entrypoint curl vmeibm/qsc-curl -kv  -H "Host:bookinfo.test" --connect-to "bookinfo.test:443:${GATEWAY_URL}"  "https://bookinfo.test:443/productpage" ; done
```
- Monitor wireshark and validate that the requests are plain HTTP requests

![plain-http-traffic.png](..%2Fimages%2Fplain-http-traffic.png)

### Validate Legacy HTTPS traffic to Ingress Gateway
- Intiate a single request to the bookinfo application
``` bash 
export GATEWAY_URL=$(kubectl get route istio-ingressgateway -n istio-system -o=jsonpath="{.spec.host}")
docker run --net host --entrypoint curl vmeibm/qsc-curl -kv  -H "Host:bookinfo.test" --connect-to "bookinfo.test:443:${GATEWAY_URL}"  "https://bookinfo.test:443/productpage"
```
- You should see the following 

![Legacy-tls-ingress.png](..%2Fimages%2FLegacy-tls-ingress.png)

## 2) Legacy HTTPS to Ingress and legacy HTTPS connection Intra-Cluster
``` bash 
helm upgrade bookinfo -n test --set intraCluster.mutualTLS=true .
```

- Intiate 10 requests to the bookinfo application
``` bash 
export GATEWAY_URL=$(kubectl get route istio-ingressgateway -n istio-system -o=jsonpath="{.spec.host}")
for i in `seq 1 10`; do  docker run --net host --entrypoint curl vmeibm/qsc-curl -kv  -H "Host:bookinfo.test" --connect-to "bookinfo.test:443:${GATEWAY_URL}"  "https://bookinfo.test:443/productpage" ; done
```
- Monitor wireshark and validate that the intra-cluster traffic is upgraded to legacy `TLSv1.2`, and uses `x25519` | `p256` curve for key exchange

![legacy-tls-intra-cluster.png](..%2Fimages%2Flegacy-tls-intra-cluster.png)

## 3) Legacy HTTPS to Ingress and Q-Safe HTTPS connection Intra-Cluster
``` bash 
helm upgrade bookinfo -n test --set intraCluster.mutualTLS=true --set intraCluster.qsc.enabled=true .
```

- Intiate 10 requests to the bookinfo application
``` bash 
export GATEWAY_URL=$(kubectl get route istio-ingressgateway -n istio-system -o=jsonpath="{.spec.host}")
for i in `seq 1 10`; do  docker run --net host --entrypoint curl vmeibm/qsc-curl -kv  -H "Host:bookinfo.test" --connect-to "bookinfo.test:443:${GATEWAY_URL}"  "https://bookinfo.test:443/productpage" ; done
```
- Monitor wireshark and validate that the intra-cluster traffic is upgraded to `TLSv1.3`, and uses `0x2f3a` (P256_Kyber512) curve for key exchange
  - You can find the list of id's and KEM algorithms [here](https://github.com/open-quantum-safe/openssl/blob/OQS-OpenSSL_1_1_1-stable/oqs-template/oqs-kem-info.md)

  ![Q-safe-tls-intra-cluster.png](..%2Fimages%2FQ-safe-tls-intra-cluster.png)
  
## 4) Q-Safe HTTPS to Ingress and Q-Safe HTTPS connection Intra-Cluster
``` bash 
helm upgrade bookinfo -n test --set intraCluster.mutualTLS=true --set intraCluster.qsc.enabled=true --set ingress.qsc.enabled=true .
```

### Validate Q-Safe HTTPS traffic to Ingress Gateway
- Intiate a single request to the bookinfo application
``` bash 
export GATEWAY_URL=$(kubectl get route istio-ingressgateway -n istio-system -o=jsonpath="{.spec.host}")
docker run --net host --entrypoint curl vmeibm/qsc-curl -kv  -H "Host:bookinfo.test" --connect-to "bookinfo.test:443:${GATEWAY_URL}"  "https://bookinfo.test:443/productpage"
```
- You should see the following (key exchange is `P256_kyber512`)

![Q-safe-ingress.png](..%2Fimages%2FQ-safe-ingress.png)

### Validate intra-cluster Q-Safe HTTPS traffic
- Intiate 10 requests to the bookinfo application
``` bash 
export GATEWAY_URL=$(kubectl get route istio-ingressgateway -n istio-system -o=jsonpath="{.spec.host}")
for i in `seq 1 10`; do  docker run --net host --entrypoint curl vmeibm/qsc-curl -kv  -H "Host:bookinfo.test" --connect-to "bookinfo.test:443:${GATEWAY_URL}"  "https://bookinfo.test:443/productpage" ; done
```
- Monitor wireshark and validate that the intra-cluster traffic is upgraded to `TLSv1.3`, and uses `0x2f3a` (P256_Kyber512) curve for key exchange
  - You can find the list of codepoints and KEM algorithms [here](https://github.com/open-quantum-safe/openssl/blob/OQS-OpenSSL_1_1_1-stable/oqs-template/oqs-kem-info.md)

    ![Q-safe-tls-intra-cluster.png](..%2Fimages%2FQ-safe-tls-intra-cluster.png)
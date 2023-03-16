#!/bin/bash
openssl req -x509 -sha256 -nodes -days 30 -newkey rsa:2048 -subj '/O=rootca Inc./CN=rootca' -keyout rootca.key -out rootca.crt

openssl req -out book-info.apps-crc.testing.csr -newkey rsa:2048 -nodes -keyout book-info.apps-crc.testing.key -subj "/CN=bookinfo.test/O=apps-crc-testing"

openssl x509 -req -days 365 -CA rootca.crt -CAkey rootca.key -set_serial 0 -in book-info.apps-crc.testing.csr -out book-info.apps-crc.testing.crt

if [[ -z "${SMCP_NS}" ]]; then
  echo -e "\n [ERROR]: The environment variable SMCP_NS is undefined. This env variable must contain the namespace where the mesh-control-plane is deployed. \n \
  Look at the instructions under mesh/mesh-control-plane/README.md to set the env variable \n"
  exit 1
else
kubectl create -n ${SMCP_NS} secret tls bookinfo-credential --key=book-info.apps-crc.testing.key --cert=book-info.apps-crc.testing.crt
fi


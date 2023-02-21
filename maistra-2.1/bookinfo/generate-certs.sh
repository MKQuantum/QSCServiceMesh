#!/bin/bash
openssl req -x509 -sha256 -nodes -days 30 -newkey rsa:2048 -subj '/O=rootca Inc./CN=rootca' -keyout rootca.key -out rootca.crt

openssl req -out book-info.apps-crc.testing.csr -newkey rsa:2048 -nodes -keyout book-info.apps-crc.testing.key -subj "/CN=bookinfo.test/O=apps-crc-testing"

openssl x509 -req -days 365 -CA rootca.crt -CAkey rootca.key -set_serial 0 -in book-info.apps-crc.testing.csr -out book-info.apps-crc.testing.crt

kubectl create -n istio-system secret tls bookinfo-credential --key=book-info.apps-crc.testing.key --cert=book-info.apps-crc.testing.crt


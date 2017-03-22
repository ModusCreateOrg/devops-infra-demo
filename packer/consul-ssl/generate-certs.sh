#!/bin/bash

COUNTRY="US"
STATE="Virginia"
LOCATION="Reston"
ORGANIZATION="Modus Create"
OU="MCHQ"
CA_CN="ConsulCA"

CN="*.infra-demo.internal"
EMAIL="infra-demo@example.com"
SAN="DNS:localhost,DNS:*.node,DNS:*.service,DNS:*.node.consul,DNS:*.service.consul,DNS:*.ec2.internal,IP:127.0.0.1"


apt-get update && apt-get install -qy openssl

echo "000a" > serial
touch certindex

# Generate ca.key and ca.crt
openssl req -new -x509 \
    -extensions v3_ca -nodes \
    -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}/O=${ORGANIZATION}/OU=${OU}/CN=${CA_CN}/emailAddress=${EMAIL}" \
    -keyout ca.key \
    -out ca.crt \
    -days 3650 -config ./openssl.cnf

# Generate consul.key
SAN=${SAN} \
    openssl genrsa \
    -out consul.key 2048 \
    -config ./openssl_req.cnf

# Generate consul.csr
SAN=${SAN} \
    openssl req -sha256 -new \
    -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}/O=${ORGANIZATION}/OU=${OU}/CN=${CN}/emailAddress=${EMAIL}" \
    -key consul.key \
    -out consul.csr \
    -config ./openssl_req.cnf

# Generate consul.crt
SAN=${SAN} \
    openssl ca -extensions usr_cert \
    -notext -md sha256 \
    -in consul.csr \
    -out consul.crt \
    -config ./openssl_req.cnf -batch

# Verify consul.crt
SAN=${SAN} \
    openssl verify -CAfile ca.crt consul.crt

# Cleanup
rm 0A.pem
rm serial*
rm certindex*

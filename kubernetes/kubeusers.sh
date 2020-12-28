#!/bin/bash

#usage:  user <storage_path>

openssl genrsa -out "$2/$1.key" 4096

# openssl genrsa -out "$2/$1.key" 2048
cat > "$2/$1.csr.cnf" <<EOL
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
[ dn ]
CN = ${1}
O = ${2}
[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
EOL
openssl req -config "$2/$1.csr.cnf" -new -key "$2/$1.key" -nodes -out "$2/$1.csr"
export BASE64_CSR=$(cat "$2/$1.csr" | base64 | tr -d '\n')
export CSR_NAME=$1-csr


cat "./csr.yml" | envsubst | kubectl apply -f -
kubectl certificate approve $1-csr
kubectl get csr $CSR_NAME -o jsonpath='{.status.certificate}' \
 | base64 --decode > "$2/$1.crt"

 kubectl apply -f role.yml
 kubectl apply -f rolebinding.yml
exit

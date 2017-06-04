#!/usr/bin/env bash

export PASSPHRASE=$1

if [ "$PASSPHRASE" == "" ]; then
    echo -n "Enter the Passphrase to encrypt the key files > "
    read PASSPHRASE
fi

echo -n "Enter Full Host Name > "
read HOST

echo -n "Enter Full Alternate Domain Names (IP:x.x.x.x,DNS:*.a.b.com) > "
read ALT

echo Enter Cert information \(Leave passphrase blank\)

openssl genrsa -aes256 -out ca-key.pem -passout pass:$PASSPHRASE 4096

openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -passin pass:$PASSPHRASE -out ca.pem

openssl genrsa -out server-key.pem 4096

openssl req -subj "/CN=$HOST" -sha256 -new -key server-key.pem -out server.csr

if [ "$ALT" == "" ]; then
    echo subjectAltName = DNS:$HOST > extfile.cnf
else
    echo subjectAltName = DNS:$HOST,$ALT > extfile.cnf
fi

openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out server-cert.pem -passin pass:$PASSPHRASE -extfile extfile.cnf

openssl genrsa -out key.pem 4096

openssl req -subj '/CN=client' -new -key key.pem -out client.csr

echo extendedKeyUsage = clientAuth > extfile.cnf

openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out cert.pem -passin pass:$PASSPHRASE -extfile extfile.cnf

rm -v client.csr server.csr

chmod -v 0400 ca-key.pem key.pem server-key.pem
chmod -v 0444 ca.pem server-cert.pem cert.pem

mkdir -p $HOST/server-certs
mkdir -p $HOST/client-certs

cp ca.pem $HOST/client-certs/
cp key.pem $HOST/client-certs/
cp cert.pem $HOST/client-certs/

cp ca.pem $HOST/server-certs/
cp server-key.pem $HOST/server-certs/
cp server-cert.pem $HOST/server-certs/

echo Done!
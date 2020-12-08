#! /bin/bash

set -e

path=`dirname $0`
#arch1=$(uname -m)

image=k8s.gcr.io/etcd:${1}
echo "" >> ${path}/group_vars/etcd.yml
echo "version: ${1}" >> ${path}/group_vars/etcd.yml

echo "etcd_version: ${1}" >> ${path}/inherent.yaml

docker pull ${image}
docker save ${image} > ${path}/file/etcd.tar
bzip2 -z --best ${path}/file/etcd.tar

echo "===xxxxxxxxxxxxx download cfssl toolsxxxxxxxxxxxxxxxxxxxx ==="
if [[ $(uname -m) == "aarch64" ]]; then
  echo "ARM64 doneeeeeee"
  wget https://dl.google.com/go/go1.12.linux-arm64.tar.gz
  tar -xf go1.12.linux-arm64.tar.gz
  export GOROOT=/usr/local/go
  pwd
  export GOPATH=
  export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
  git clone https://github.com/cloudflare/cfssl
  cd cfssl
  make install && cd bin
  chmod +x cfssl cfssljson cfssl-certinfo
  tar zcvf ${path}/file/cfssl-tools.tar.gz cfssl cfssl-certinfo cfssljson
  cd ../..
  rm -rf cfssl
else
  echo "AMD64 doneeeee"
fi
export CFSSL_URL=https://pkg.cfssl.org/R1.2
curl -L -o cfssl ${CFSSL_URL}/cfssl_linux-amd64
curl -L -o cfssljson ${CFSSL_URL}/cfssljson_linux-amd64
curl -L -o cfssl-certinfo ${CFSSL_URL}/cfssl-certinfo_linux-amd64
chmod +x cfssl cfssljson cfssl-certinfo
tar zcvf ${path}/file/cfssl-tools.tar.gz cfssl cfssl-certinfo cfssljson
echo "=== cfssl tools is download successfully ==="

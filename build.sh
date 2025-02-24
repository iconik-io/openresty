#! /bin/bash -x

sudo chown -R jenkins: $WORKSPACE || /bin/true

docker build -t openresty-build .

docker run -e "BUILD_NUMBER=${BUILD_NUMBER}" --rm -v "$PWD:$PWD" -w "$PWD" openresty-build make



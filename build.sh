#! /bin/bash -x

docker build -t openresty-build .

docker run --rm -v "$PWD:$PWD" -w "$PWD" openresty-build make



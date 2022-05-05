#!/bin/bash
image=clusterfuzz-env

mkdir ./config
docker run --rm -it -v "$(pwd)/files:/files" -v "$(pwd)/config:/config" --env-file "$(pwd)/files/environment.txt" $image
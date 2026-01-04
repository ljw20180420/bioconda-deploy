#!/bin/bash

source "update_meta.sh"

cp recipes/rearr/meta.yaml.shit recipes/rearr/meta.yaml
update_meta https://github.com/ljw20180420/rearr/archive/refs/tags/v1.0.11.tar.gz

cmp -s recipes/rearr/meta.yaml recipes/rearr/meta.yaml.correct

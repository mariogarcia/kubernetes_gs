#!/usr/bin/env bash

set -e

mkdir -p /home/kubi/.kube
cp -i /etc/kubernetes/admin.conf /home/kubi/.kube/config
chown -R kubi:kubi /home/kubi/.kube

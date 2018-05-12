#!/usr/bin/env bash

set -e

kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address={{ master_ip }}

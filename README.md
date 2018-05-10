# Kubernetes cluster

This project install Kubernetes in three different machines using
Ubuntu/Xenial64. In order to configure the cluster you should follow
certain steps.

## Building vagrant box

Go to every of the machines directories and execute:

```shell
vagrant up
```

Because all machines will have a bridged network interface you will be
prompted to chose which bridged interface will the machine be using.

## Initializing the cluster

I'm choosing `sherlock` as the master node. So you have to go to the
`sherlock` directory enter the vagrant machine and execute:

```shell
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.250.38
```

Where `--pod-network-cidr=10.244.0.0/16` can remain the same (it's a
requirement from flannel cid network) and
`--apiserver-advertise-address=192.168.250.38` should be the ip where
the master will be available to slave nodes. This execution will show the join
command line that has to be executed in slave nodes afterwards. But first you
have to install the `POD network`.

## Installing POD network

There are several pod network choices, but I'm using `flannel` because
it's fully compatible with both load balancer `metallb` and the
`openebs` distributed storage solution.

One of the requirements of `flannel` is to initialize the master cluster with a specific
`--pod-network-cidr` parameter. Because we've already done this we can move forward and install it via `kubectl`:

```shell
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
```

## Installing Load Balancer

The only load balancer available to work with kubernetes and baremetal
is MetalLB. You can install it with kubectl:

```shell
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.6.2/manifests/tutorial-2.yaml
```

Now it's time to configure a pool of available public IPs that will be
handled by MetalLB. Because I've available `192.168.250.110/29` that's
the range of IPs I'm giving to the pool:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: my-ip-space
      protocol: layer2
      addresses:
      - 192.168.250.112/29
```

I'm saving that configuration to `metallb-config.yaml` and then I create
that configuration in kubernetes:

```shell
kubectl create -f metallb-config.yaml
```

Now you can use this configuration in a kubernetes service. When
asking for exposing your service through the load balancer it will
expose the service in any of the public ips available in the pool.

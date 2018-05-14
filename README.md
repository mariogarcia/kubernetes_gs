# Kubernetes cluster

This project installs a Kubernetes cluster in a Vagrant box with
Ubuntu/Xenial64.

## Configuration

First of all you have to enumerate all nodes you want your cluster to
have. By default there's only one master and one slave. This can be
found in the `Vagrantfile`:



```ruby
  # master ip
  master_ip = "192.168.250.102"

  # cluster default gateway ip
  gateway_ip = "192.168.250.1"

  # metallb network mask to get ips from the pool
  metallb_netmask = "192.168.250.112/29"

  # nodes to be built
  nodes = {
    "sherlock": {
      ip: master_ip,
      is_master: true,
      memory: "4096",
      disk: "10GB"
    },
    "watson": {
      ip: "192.168.250.103",
      is_master: false,
      memory: "4096",
      disk: "10GB"
    }
  }
```

Master IP will be used in Kubernetes initialization as the master
advertise address `--apiserver-advertise-address`:

```shell
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.250.38
```

Apart from the static public IP defined in the nodes map, you have
also to set which is the default gateway of the cluster:

```ruby
add_gateway_command = "route add default gw 192.168.250.1"
```

## Installation

Go to the project root folder and execute:

```shell
vagrant up
```

Because all machines will have a bridged network interface you will be
prompted to chose which bridged interface to use.

There're more information about how to configure networks with vagrant at:
https://www.vagrantup.com/docs/networking/public_network.html

## Components installed

### POD network

There are several pod network choices, but I'm using `flannel` because
it's fully compatible with both load balancer `metallb` and the
`openebs` distributed storage solution.

One of the requirements of `flannel` is to initialize the master
cluster with a specific `--pod-network-cidr` parameter. Because we've
already done this we can move forward and install it via `kubectl`:

### Load Balancer

The only load balancer available to work with kubernetes and baremetal
is MetalLB.

Now it's time to configure a pool of available public IPs that will be
handled by MetalLB. By default the image is using a layer 2 strategy
with `192.168.250.110/29` netmask as the range of IPs I'm giving to
the pool:

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

You can change the netmask in `Vagrantfile`.

The following example is taken from the `metallb` tutorial and
installs an `nginx` and ask the load balancer to expose it in an
available ip:

```shell
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.6.2/manifests/tutorial-2.yaml
```

Aterwards you can execute the following command to check where the
service has been exposed:

```shell
watch kubectl get services
```

At some point you will see something like this:

```shell
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)        AGE
kubernetes   ClusterIP      10.96.0.1       <none>            443/TCP        2h
nginx        LoadBalancer   10.110.154.95   192.168.250.112   80:32293/TCP   2h
```

Then you can go and browse `http://192.168.250.112`

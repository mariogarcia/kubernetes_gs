Vagrant.configure("2") do |config|

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

  # shell provisioning
  del_default_gateway = "route del default gw 0"
  add_gateway_command = "route add default gw #{ gateway_ip }"

  # loop through all configured nodes
  nodes.each { |name, ndata|
    config.vm.define name do |node|
      node.vm.box = "ubuntu/xenial64"
      node.disksize.size = ndata[:disk]
      node.vm.hostname = name
      node.vm.network "public_network", ip: ndata[:ip]

      node.vm.provision "shell", inline: del_default_gateway
      node.vm.provision "shell", inline: add_gateway_command

      node.vm.provider "virtualbox" do |vb|
        vb.memory = ndata[:memory]
      end

      node.vm.provision "ansible" do |ansible|
        ansible.playbook = "ansible/playbook-#{ ndata[:is_master] ? 'master' : 'slave' }.yml"
        ansible.extra_vars = {
          master_ip: master_ip,
          metallb_addresses: metallb_netmask
        }
      end

    end
  }
end

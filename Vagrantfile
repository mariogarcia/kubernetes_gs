Vagrant.configure("2") do |config|

  # node configurations
  nodes = {
    "sherlock": {
      ip: "192.168.250.102",
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
  add_gateway_command = "route add default gw 192.168.250.1"

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
      end

    end
  }
end

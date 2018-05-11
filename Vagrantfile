Vagrant.configure("2") do |config|

  machines = {
    "sherlock" => "192.168.250.102",
    "watson"   => "192.168.250.103"
  }

  machines.each { |name, ip|
    config.vm.define name do |node|
      node.vm.box = "ubuntu/xenial64"
      node.disksize.size = '10GB'
      node.vm.hostname = name
      node.vm.network "public_network", ip: ip
      node.vm.provision "shell",
                        run: "always",
                        inline: "route add default gw 192.168.250.1"

      node.vm.provider "virtualbox" do |vb|
        vb.memory = "4096"
      end

      node.vm.provision "ansible" do |ansible|
        ansible.playbook = "provisioning/playbook.yml"
      end
    end
  }
end

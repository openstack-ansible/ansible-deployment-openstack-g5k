# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.ssh.insert_key = false

  config.vm.define "compute-001" do |machine|
    machine.vm.box = "ubuntu/trusty64"
    machine.vm.hostname = "compute-001"
    machine.vm.network :private_network, ip: "10.1.0.4",
                       :netmask => "255.255.0.0"
    machine.vm.provider :virtualbox do |v| 
      v.customize ["modifyvm", :id, "--memory", 1280]
    end
  end

  config.vm.define "controller", primary: true do |machine|
    machine.vm.box = "ubuntu/trusty64"
    machine.vm.hostname = "controller"
    machine.vm.network "forwarded_port", guest: 80, host: 8080
    machine.vm.network :private_network, ip: "10.1.0.2",
                       :netmask => "255.255.0.0"
    machine.vm.provider :virtualbox do |v| 
      v.customize ["modifyvm", :id, "--memory", 2048]
      v.customize ["modifyvm", :id, "--nicpromisc2", "allow-vms"]
    end

    machine.vm.provision "ansible" do |ansible|
      ansible.playbook = "getreqs.yml"
    end

    machine.vm.provision "ansible" do |ansible|
      ansible.playbook = "prepare-vm.yml"
    end

    machine.vm.provision "ansible" do |ansible|
      ansible.playbook = "deploy.yml"
      ansible.groups = {
        "controller" => ["controller"],
        "network" => ["controller"],
        "compute" => ["compute-001"]
      }
      ansible.extra_vars = {
        openstack_controller_ip: "10.1.0.2",
        openstack_network_external_device: "eth1",
        openstack_network_external_gateway: "10.1.0.2",
        openstack_network_local_ip: 
          "{{ ansible_all_ipv4_addresses|ipaddr('10.1.0.0/16')|first }}",
        openstack_compute_node_ip: 
          "{{ ansible_all_ipv4_addresses|ipaddr('10.1.0.0/16')|first }}",
        openstack_horizon_url: "http://localhost:8080/horizon"
      }
      ansible.limit = 'all'
    end

    machine.vm.provision "ansible" do |ansible|
      ansible.playbook = "test.yml"
      ansible.groups = {
        "controller" => ["controller"]
      }
    end

  end

end

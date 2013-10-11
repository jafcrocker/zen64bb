# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "cent64-minimal"
  config.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130427.box"
  config.vm.hostname =  Dir.pwd.split('/')[-1] + "-vm"
  config.vm.network :private_network, type: :dhcp,  ip: "192.168.0.0", netmask: "255.255.255.0" 
  #config.vm.network "public_network", :bridge => 'eth0'
  #config.vm.synced_folder "./src", "/home/zenoss/work", owner: "zenoss", group: "zenoss"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "6144"]
    vb.customize ["modifyvm", :id, "--cpus", 4]
  end

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "cookbooks"

    # All prereqs for building Zenoss Core
    chef.add_recipe "buildbox"

    # Add hooks for Impact development
    chef.add_recipe "buildbox::impact"

    # Add the daemons.txt files
    chef.add_recipe "buildbox::daemons_txt"
  end

end


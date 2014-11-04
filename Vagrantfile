# -*- mode: ruby -*-
# vi: set ft=ruby :

$cwd =  File.expand_path(File.dirname(__FILE__))
$hostname = ($cwd.split('/')[-1] + "-vm").gsub(/[^a-zA-Z0-9]/, "-")

Vagrant.configure("2") do |config|
  config.vm.box = "cent64-zenoss_users"
  config.vm.box_url = "http://vagrant.zendev.org/boxes/centos-6.4-x64-zenoss_users.box"
  config.vm.hostname = $hostname
  config.vm.synced_folder "./src", "/home/zenoss/work", owner: "zenoss", group: "zenoss"
  config.vm.network :private_network, type: :dhcp,  ip: "192.168.0.0", netmask: "255.255.255.0" 
  config.vm.network "forwarded_port", guest: 8080, host: 6990, auto_correct: true
  #config.vm.network "public_network", :bridge => 'eth0'

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "6144"]
    vb.customize ["modifyvm", :id, "--cpus", 4]
  end

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "cookbooks"

    # All prereqs for building/runnning Zenoss Core
    chef.add_recipe "buildbox"

    # Add zenoss-user specific configuration
    chef.add_recipe "buildbox::zenoss"

    # Add hooks for Impact development
    chef.add_recipe "buildbox::impact"

    # Add the daemons.txt files
    chef.add_recipe "buildbox::daemons_txt"
  end

end


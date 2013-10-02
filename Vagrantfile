# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "cent64-minimal"
  config.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130427.box"
  config.vm.hostname =  Dir.pwd.split('/')[-1] + "-vm"
  #config.vm.synced_folder "./src", "/home/zenoss/work", owner: "zenoss", group: "zenoss"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "6144"]
    vb.customize ["modifyvm", :id, "--cpus", 4]
  end
  #

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "cookbooks"
    chef.add_recipe "buildbox"

    # Add hooks for impact development
    #chef.add_recipe "buildbox::impact"
  end

end


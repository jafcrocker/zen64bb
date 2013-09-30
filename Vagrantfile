# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "zen64bb"
  config.vm.box_url = "http://developer.nrel.gov/downloads/vagrant-boxes/CentOS-6.4-x86_64-v20130427.box"
  # config.vm.hostname = "YOURNAME.zenoss.loc"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "6144"]
    vb.customize ["modifyvm", :id, "--cpus", 4]
  end
  #

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "cookbooks"
    chef.add_recipe "buildbox"
  end
end

#sudo su - zenoss
#svn co http://dev.zenoss.com/svnint/branches/core/zenoss-4.x/inst
#./configure --with-rrdtool=yes --prefix=/opt/zenoss

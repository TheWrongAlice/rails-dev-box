# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/trusty64'
  config.vm.boot_timeout = 400
  config.vm.provider 'virtualbox' do |v|
    v.memory = 2048
    v.customize ['guestproperty', 'set', :id, '--timesync-threshold', 5000]
  end
  config.vm.provision :shell, path: 'vagrant/bootstrap.sh'
  config.vm.provision :shell, path: 'vagrant/create_self_signed_config.sh'
  config.vm.provision :shell, path: 'vagrant/create_default_config.sh'
  config.vm.network 'forwarded_port', guest: 80, host: 3000
  config.vm.network 'forwarded_port', guest: 443, host: 3043
  config.vm.network 'forwarded_port', guest: 5432, host: 5432
end

VAGRANTFILE_API_VERSION = '2'
require 'date'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "ubuntu/xenial64"
    config.vm.hostname = "roadiz-se-" + Time.now.strftime("%Y%m%d")
    #
    # Use forwarded ports with your local network
    # Be careful to change port if you want to run multiple
    # Vagrant boxes
    #
    config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true # Nginx
    config.vm.network "forwarded_port", guest: 443, host: 4430, auto_correct: true # Nginx SSL
    config.vm.network "forwarded_port", guest: 8983, host: 8983, auto_correct: true # Solr
    config.vm.network "forwarded_port", guest: 1080, host: 1080, auto_correct: true # Mailcatcher

    config.vm.synced_folder './', '/vagrant'

    config.vm.provider "virtualbox" do |vb|
        vb.memory = 2048
        vb.cpus = 4
        vb.customize ['modifyvm', :id, '--memory', '2048']
        vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
        vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
        vb.customize ['modifyvm', :id, '--uartmode1', 'disconnected']
    end

    config.vm.provision "roadiz",      type: :shell, path: "scripts/vagrant-php7-provisioning.sh"
    config.vm.provision "phpmyadmin",  type: :shell, path: "scripts/vagrant-phpmyadmin-provisioning.sh"
    config.vm.provision "mailcatcher", type: :shell, path: "scripts/vagrant-php7-mailcatcher-provisioning.sh"
    config.vm.provision "solr",        type: :shell, path: "scripts/vagrant-solr-provisioning.sh"
    config.vm.provision "devtools",    type: :shell, path: "scripts/vagrant-devtools-provisioning.sh"
    config.vm.provision "purge",       type: :shell, path: "scripts/vagrant-purge.sh"

    config.push.define "atlas" do |push|
        push.app = "roadiz/standard-edition"
    end
end

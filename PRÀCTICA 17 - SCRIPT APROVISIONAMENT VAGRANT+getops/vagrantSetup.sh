#!/bin/bash

# Importem la box Ubuntu server i creem el vagrantfile
echo -e "Vagrant.configure('2') do |config|
  config.vm.box = 'peru/ubuntu-18.04-server-amd64'
  config.vm.box_version = '20201107.01'" > Vagrantfile

# Establim la memòria de la màquina a 2GB
echo -e " config.vm.provider 'virtualbox' do |vb|
   vb.memory = '2048'
 end" >> Vagrantfile

# Creem el script de provisionament inline per a LAMP i adminer
echo -e " config.vm.provision "shell", inline: <<-SHELL
   apt update
   apt install -y apache2
   ufw allow in 'Apache Full'
   apt install mysql-server
   apt install php libapache2-mod-php php-mysql
   systemctl restart apache2
   apt install -y git
   git clone 'https://github.com/vrana/adminer.git'
   git submodule update --init
 SHELL
end" >> Vagrantfile

# Llança Vagrant
vagrant up

# Espera uns quants segonts i s'hi connecta

sleep(10)
vagrant ssh
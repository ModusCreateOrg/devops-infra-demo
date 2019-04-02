Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7.5"
  config.vm.synced_folder ".", "/app"
  config.vm.provision "shell", inline: "/app/bin/install-ansible.sh", upload_path: "/home/vagrant/install-ansible.sh"
  config.vm.provision "shell", inline: "cd /app/ansible && ansible-playbook  -l localhost bakery.yml app-AfterInstall.yml app-StartServer.yml", upload_path: "/home/vagrant/apl.sh"
  config.vm.provision "shell", inline: "curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -"
  config.vm.provision "shell", inline: "curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -"
  config.vm.provision "shell", inline: "curl -L get.rvm.io | bash -s stable"
  config.vm.provision "shell", inline: "source /etc/profile.d/rvm.sh"
  config.vm.provision "shell", inline: "rvm reload"
  config.vm.provision "shell", inline: "rvm requirements run"
  config.vm.provision "shell", inline: "rvm install 2.6"
  config.vm.provision "shell", inline: "rvm alias create default ruby-2.6.0"
  config.vm.provision "shell", inline: "rvm list && rvm use 2.6 --default && ruby --version"
  config.vm.provision "shell", inline: "yum -y install ruby-devel && gem install gauntlt" 
  config.vm.network "forwarded_port", guest: 80, host: 6080, auto_correct: true
end

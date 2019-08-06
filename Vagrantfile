Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7.5"
  config.vm.synced_folder ".", "/app"
  config.vm.provision "shell", inline: "/app/bin/install-gauntlt.sh", upload_path: "/home/vagrant/install-gauntlt.sh"
  config.vm.provision "shell", inline: "/app/bin/install-ansible.sh", upload_path: "/home/vagrant/install-ansible.sh"
  config.vm.provision "shell", inline: "cd /app/ansible && ansible-playbook  -l localhost bakery.yml scan-openscap.yml scan-gauntlt.yml app-AfterInstall.yml app-StartServer.yml", upload_path: "/home/vagrant/apl.sh"
  config.vm.network "forwarded_port", guest: 80, host: 6080, auto_correct: true
end

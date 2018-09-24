Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7.5"
  config.vm.synced_folder "packer", "/app"
  config.vm.provision "shell", inline: "/app/bin/install-ansible.sh", upload_path: "/home/vagrant/install-ansible.sh"
  config.vm.provision "shell", inline: "ansible-playbook  -l localhost /app/ansible/local.yml", upload_path: "/home/vagrant/apl.sh"
  config.vm.network "forwarded_port", guest: 80, host: 6080, auto_correct: true
end

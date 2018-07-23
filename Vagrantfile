Vagrant.configure("2") do |config|
  config.vm.box = "geerlingguy/centos7"
  config.vm.synced_folder "packer", "/app"
  config.vm.provision "shell", inline: "/app/bin/install-ansible.sh", upload_path: "/home/vagrant/install-ansible.sh"
  config.vm.provision "shell", inline: "ansible-playbook  -l localhost /app/ansible/local.yml", upload_path: "/home/vagrant/apl.sh"
  config.vm.provision "shell", inline: "/app/bin/scan.sh", upload_path: "/home/vagrant/scan.sh"
end
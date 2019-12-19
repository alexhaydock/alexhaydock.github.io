# -*- mode: ruby -*-
# vi: set ft=ruby :

# This example box will deploy my site inside Docker on
# a VirtualBox VM which listens on :8080 on the host
# (:80 internally on the guest VM and my site's container).

Vagrant.configure("2") do |config|

  # Define box
  config.vm.box = "ubuntu/bionic64"

  # Define networking
  config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Run Nginx
  config.vm.provision "docker" do |d|
    d.run "registry.gitlab.com/alexhaydock/alexhaydock.co.uk",
      args: "-p 80:80/tcp"
  end

end
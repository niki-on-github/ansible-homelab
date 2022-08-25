# -*- mode: ruby -*-
# vi: set ft=ruby :
# Description:
#   We use vagrant to test the ansible playbooks
#
# Usage:
#   vagrant up --provision

require 'yaml'

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'

current_dir = File.dirname(File.expand_path(__FILE__))
configs = YAML.load_file("#{current_dir}/tests/config.yml")
vagrant_config = configs['configs'][configs['configs']['use']]

Vagrant.configure("2") do |config|

  config.vm.box = vagrant_config['box']
  config.vm.box_check_update = false
  config.vm.synced_folder ".", "/vagrant", type: "rsync"

  config.vm.provider :libvirt do |libvirt|
    libvirt.cpus = vagrant_config['cpus']
    libvirt.cputopology :sockets => '1', :cores => vagrant_config['cpus'].to_s(), :threads => '1'
    libvirt.nested = true
    libvirt.memory = vagrant_config['memory']
    libvirt.graphics_type = "spice"
    libvirt.video_type = "virtio"
    libvirt.channel :type => 'spicevmc', :target_name => 'com.redhat.spice.0', :target_type => 'virtio'
    libvirt.machine_virtual_size = vagrant_config['disksize']
  end

  config.vm.provision :ansible do |ansible|
    # ansible.galaxy_role_file = 'requirements.yml'
    ansible.verbose = "vv"
    ansible.playbook = "./playbooks/docker.yml"
    ansible.limit = "all"
    ansible.groups = { vagrant_config['group'] => ["default"] }
    ansible.extra_vars = {
      vagrant: true,
      username: "vagrant",
      domain: 'test01.lan',
      gateway_ip: "10.0.1.1",
      server_ip: "127.0.0.1",
      webservices_password: "test",
      network_address: "192.168.1.0/16",
      network_ip: "192.168.1.0"
    }
  end

end

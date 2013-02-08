# -*- mode: ruby -*-
# vi: set ft=ruby :

# Copyright 2013 Zürcher Hochschule für Angewandte Wissenschaften
# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

Vagrant::Config.run do |config|

  config.vm.define :os_aio do |os_aio_config|

    os_aio_config.vm.box = "precise64"
    os_aio_config.vm.box_url = "http://files.vagrantup.com/precise64.box"

    os_aio_config.vm.boot_mode = :gui
    # os_aio_config.vm.network  :hostonly, "10.1.2.44" #:hostonly or :bridged - default is NAT
    os_aio_config.vm.host_name = "os-aio"
    os_aio_config.vm.customize ["modifyvm", :id, "--memory", 1024]
    os_aio_config.ssh.max_tries = 100
    os_aio_config.vm.forward_port 80, 8080
    os_aio_config.vm.provision :shell, :inline => "apt-get update"

    os_aio_config.vm.provision :puppet do |devstack_puppet|
      devstack_puppet.pp_path = "/tmp/vagrant-puppet"
      devstack_puppet.module_path = "modules"
      devstack_puppet.manifests_path = "manifests"
      devstack_puppet.manifest_file = "site.pp"
    end
  end
end

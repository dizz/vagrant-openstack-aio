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

node /^os-aio/ {

	$public_interface = 'eth1'
	$private_interface = 'eth1'
	$admin_email = 'root@localhost'
	$admin_password = 'keystone_admin'
	$keystone_db_password = 'keystone_db_pass'
	$keystone_admin_token = 'keystone_admin_token'
	$nova_db_password = 'nova_pass'
	$nova_user_password = 'nova_pass'
	$glance_db_password = 'glance_pass'
	$glance_user_password = 'glance_pass'
	$rabbit_password = 'openstack_rabbit_password'
	$floating_network_range = '10.1.2.64/28'
	$verbose = true
	$auto_assign_floating_ip = false
	$libvirt_type = 'qemu'
	$secret_key = 'secret_key'
	$mysql_root_password = 'a_super_password'

	apt::source { 'openstack_folsom':
		location	=> "http://ubuntu-cloud.archive.canonical.com/ubuntu",
		release		=> "precise-updates/folsom",
		repos		=> "main",
		required_packages => 'ubuntu-cloud-keyring',
	}
	exec { '/usr/bin/apt-get update':
		refreshonly => true,
		logoutput   => true,
		subscribe   => [Apt::Source["openstack_folsom"]],
	}
	Exec['/usr/bin/apt-get update'] -> Package<||>

	include 'apache'
	
	class { 'cinder::setup_test_volume': } -> Service<||>

	class { 'openstack::all':
		public_address => $ipaddress_eth0,
		public_interface => $public_interface,
		private_interface => $private_interface,
		admin_email => $admin_email,
		mysql_root_password => $mysql_root_password,
		admin_password => $admin_password,
		rabbit_password => $rabbit_password,
		keystone_db_password => $keystone_db_password,
		keystone_admin_token => $keystone_admin_token,
		glance_db_password => $glance_db_password,
		glance_user_password => $glance_user_password,
		nova_db_password => $nova_db_password,
		nova_user_password => $nova_user_password,
		secret_key => $secret_key,
		libvirt_type => $libvirt_type,
		floating_range => $floating_network_range,
		verbose => $verbose,
		auto_assign_floating_ip => $auto_assign_floating_ip,
	}

	class { 'openstack::auth_file':
		admin_password       => $admin_password,
		keystone_admin_token => $keystone_admin_token,
		controller_node      => '127.0.0.1',
	}
}

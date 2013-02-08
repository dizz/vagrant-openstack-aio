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

	group { 'puppet':
		ensure => 'present',
	}
$cnt = "
domain test
nameserver 10.0.2.3
"
	file { "/etc/resolv.conf":
		content 	=> "$cnt",
		group		=> "root",
		owner		=> "root",
    }

    /*package { "ubuntu-cloud-keyring":
    	ensure		=> installed,
    	require 	=> File["/etc/resolv.conf"]
    }*/

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

	$mysql_root_password = "admin"
	$keystone_db_password = "admin"
	$glance_db_password = "admin"
	$nova_db_password = "admin"
	$cinder_db_password = "admin"
	$quantum_db_password = "admin"
	$allowed_hosts = "admin"

	# 1. setup mysql
	class { 'openstack::db::mysql':
	    mysql_root_password  => $mysql_root_password,
	    keystone_db_password => $keystone_db_password,
	    glance_db_password   => $glance_db_password,
	    nova_db_password     => $nova_db_password,
	    cinder_db_password   => $cinder_db_password,
	    quantum_db_password  => $quantum_db_password,
	    allowed_hosts        => $allowed_hosts,
	}

	# 2. Setup keystone
	$mysql_host = "0.0.0.0"
	$admin_token = "admin"
	$admin_email = "admin@localhost"
	$admin_password = "admin"
	$glance_user_password = "admin"
	$nova_user_password = "admin"
	$cinder_user_password = "admin"
	$quantum_user_password = "admin"
	$keystone_host = "localhost"
	$glance_host = "localhost"
	$nova_host = "localhost"
	$verbose = true

	/*keystone_config {
    	'DEFAULT/log_config': ensure => absent,
	}*/

	class { 'openstack::keystone':
	    db_host               => $mysql_host,
	    db_password           => $keystone_db_password,
	    admin_token           => $admin_token,
	    admin_email           => $admin_email,
	    admin_password        => $admin_password,
	    glance_user_password  => $glance_user_password,
	    nova_user_password    => $nova_user_password,
	    cinder_user_password  => $cinder_user_password,
	    quantum_user_password => $quantum_user_password,
	    public_address        => $keystone_host,
	    glance_public_address => $glance_host,
	    nova_public_address   => $nova_host,
	    verbose               => $verbose,
	    require               => Class['openstack::db::mysql'],
	}

	class { 'openstack::glance':
		db_host               => $mysql_host,
		glance_user_password  => $glance_user_password,
		glance_db_password    => $glance_db_password,
		keystone_host         => $keystone_host,
		auth_uri              => "http://${keystone_host}:5000/",
		verbose               => $verbose,
		require               => Class['openstack::keystone'],
	}

	class { 'openstack::test_file': }

	$controller_host = "localhost"
	$public_interface = "eth0"
	$private_interface = "eth1"
	$rabbit_password = "admin"
	class { 'openstack::nova::controller':
	    public_address     => $controller_host,
	    public_interface   => $public_interface,
	    private_interface  => $private_interface,
	    db_host            => $mysql_host,
	    rabbit_password    => $rabbit_password,
	    nova_user_password => $nova_user_password,
	    nova_db_password   => $nova_db_password,
	    network_manager    => 'nova.network.manager.FlatDHCPManager',
	    verbose            => $verbose,
	    multi_host         => true,
	    glance_api_servers => "http://${glance_host}:9292",
	    keystone_host      => $keystone_host,
	    #floating_range          => $floating_network_range,
	    #fixed_range             => $fixed_network_range,
  	}

  	$secret_key = "admin"
  	class { 'openstack::horizon':
	    secret_key            => $secret_key,
	    cache_server_ip       => '127.0.0.1',
	    cache_server_port     => '11211',
	    swift                 => false,
	    quantum               => false,
	    horizon_app_links     => undef,
	    keystone_host         => $keystone_host,
	    keystone_default_role => 'Member',
	}

	/*class { 'cinder':
	    rabbit_password => $rabbit_password,
	    # TODO what about the rabbit user?
	    rabbit_host     => $controller_host,
	    sql_connection  => "mysql://cinder:${cinder_db_password}@${mysql_host}/cinder?charset=utf8",
	    verbose         => $verbose,
	}

	class { 'cinder::volume': }

	class { 'cinder::volume::iscsi': }*/

	class { 'openstack::auth_file':
		admin_password       => $admin_password,
		keystone_admin_token => $admin_token,
		controller_node      => $keystone_host,
	}
}
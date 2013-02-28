# OpenStack AIO

This vagrant project will allow you create an OpenStack all in one installation using the `vagrant up` command.

## Installing
* Install virtualbox and vagrant
* Checkout the code ;-) - use the `--recursive` flag with `git clone`. There are external submodules to download
* `cd` into the checked out directory
* `vagrant up`
* Get a coffee...

## Gotchas
* Currently there is a bug in `modules/openstack/manifests/all.pp:295`. Comment this line out. There is a [patch submitted](https://github.com/puppetlabs/puppetlabs-openstack/pull/167) to the repository owner.
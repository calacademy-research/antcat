VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.hostname = 'antcat-dev'

  config.vm.network :private_network, ip: '192.168.50.50'
  config.vm.synced_folder '.', '/vagrant', nfs: true # requires sudo upon installation

  config.vm.network :forwarded_port, guest: 3000, host: 3000

  # from https://stefanwrobel.com/how-to-make-vagrant-performance-not-suck
  config.vm.provider "virtualbox" do |v|
    host = RbConfig::CONFIG['host_os']

    if host =~ /darwin/
      cpus = `sysctl -n hw.ncpu`.to_i
      mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 2
    elsif host =~ /linux/
      cpus = `nproc`.to_i
      mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4
    else # sorry Windows folks, I can't help you
      cpus = 2
      mem = 1024
    end

    v.customize ["modifyvm", :id, "--memory", mem]
    v.customize ["modifyvm", :id, "--cpus", cpus]
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["cookbooks"]
    chef.add_recipe 'rvm::user'
    chef.add_recipe 'nodejs'
    chef.add_recipe 'jetty'           # solr dep
    chef.add_recipe 'xvfb'            # X virtual framebuffer for running headless tests
    chef.add_recipe "mysql::server"
    chef.add_recipe "mysql::client"
    chef.add_recipe 'curl::libcurl'
    chef.add_recipe 'libqt4'          # test dep

    mysql_password = ENV['MYSQL_PASSWORD'] || 'lasius'
    chef.json = {
        rvm: {
            rvmrc: {
                rvm_autolibs_flag: "disabled"
            },
            user_installs: [{
                rubies: [ '2.1.2' ],
                default_ruby: 'ruby-2.1.2',
                user: 'vagrant',
                code: 'rvm use 2.1.2',
                global_gems: [ { name: 'rake' }, { name: 'bundler' } ]
            }]
        },
        mysql: {
            server_root_password: "#{mysql_password}"
        }
    }
  end

  config.vm.provision :shell, name: "profile", privileged: false, inline: %[
    echo "export HEADLESS=true" >> /home/vagrant/.profile
    echo "export VAGRANT=true" >> /home/vagrant/.profile
    echo "cd /vagrant" >> /home/vagrant/.bashrc
  ]

  config.vm.provision :shell, name: "bundle gems", privileged: false, inline: %[
    cd /vagrant
    bundle install --without production
  ]

  config.vm.provision :shell, name: "rails stuff", privileged: false, inline: %[
    cd /vagrant
    bundle exec rake db:create
    #bundle exec rake db:schema:load # warning: potentially destructive command
  ]
end

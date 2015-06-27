# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

CLOUD_CONFIG_PATH = File.join(File.dirname(__FILE__), "user-data")
CONFIG = File.join(File.dirname(__FILE__), "config.rb")

$update_channel = "alpha"
nodes = [
    {
        :name => 'Feedient-Dev',
        :ip => '172.17.8.2',
        :box => "coreos-%s" % $update_channel,
        :url => "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % $update_channel,
        :version => ">= 308.0.1",
        :ram => 1024,
        :cpus => 1,
        :gui => false
    }
]

# shared_dir: <Destination>:<Location>
# TODO: Add timeout delay too nginx
forwardPorts = [ 27017, 80, 8000 ]
dockerContainers = [
    {
        :name => 'mongodb_server',
        :ports => '27017:27017',
        :environment => 'development',
        :shared_dir => '/var/lib/data:/data/db -v /home/core/share/logs/mongodb_server:/var/log',
        :start_shell => false,
        :required_dir => false
    },
    # {
    #     :name => 'ghost_demo',
    #     :ports => '60001:2368',
    #     :environment => 'development',
    #     :start_shell => false
    # },
    {
        :name => 'frontend_server',
        :ports => '80:80',
        :environment => 'development',
        :shared_dir => '/home/core/share/www:/var/www -v /home/core/share/logs/frontend_server:/var/log',
        :start_shell => false,
        :required_dir => "/home/core/share/www/feedient.com"
    },
    {
        :name => 'api_server',
        :ports => '8000:8000',
        :environment => 'development',
        :shared_dir => '/home/core/share/www:/var/www -v /home/core/share/logs/api_server:/var/log',
        :start_shell => false,
        :required_dir => "/home/core/share/www/api.feedient.com"
    }
]

# Defaults for config options defined in CONFIG
$update_channel = "alpha"
$enable_serial_logging = false

Vagrant.configure("2") do |config|
    nodes.each do |node|
        config.vm.define node[:name] do |node_config|
            nfs_setting = RUBY_PLATFORM =~ /darwin/ || RUBY_PLATFORM =~ /linux/

            # IF NO NFS: node_config.vm.synced_folder "www", "/var/www"
            #node_config.vm.synced_folder "www", "/var/www", :nfs => true, :mount_options => ['nolock,vers=3,udp']
            node_config.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true,  :mount_options   => ['nolock,vers=3,udp']

            # Configure Machine details
            node_config.vm.box = node[:box]
            node_config.vm.box_url = node[:url]
            node_config.vm.box_version = node[:version]
            node_config.vm.hostname = node[:name]

            # Private network
            config.ssh.forward_agent = true
            node_config.vm.network :private_network, ip: node[:ip]

            # Forwards ports 60000 - 60010
            (60000..6010).each do |port|
                config.vm.network :forwarded_port, :host => port, :guest => port
            end

            forwardPorts.each do |port|
                config.vm.network :forwarded_port, :host => port, :guest => port
            end

            # Copy over the machine discovery file when set
            if File.exist?(CLOUD_CONFIG_PATH)
              config.vm.provision :file, :source => "#{CLOUD_CONFIG_PATH}", :destination => "/tmp/vagrantfile-user-data"
              config.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true
            end

            config.vm.provider :virtualbox do |v|
                # On VirtualBox, we don't have guest additions or a functional vboxsf
                # in CoreOS, so tell Vagrant that so it can be smarter.
                v.check_guest_additions = false
                v.functional_vboxsf     = false
            end

            # plugin conflict
            if Vagrant.has_plugin?("vagrant-vbguest") then
                config.vbguest.auto_update = false
            end

            # Serial logging
            if $enable_serial_logging
              logdir = File.join(File.dirname(__FILE__), "log")
              FileUtils.mkdir_p(logdir)

              serialFile = File.join(logdir, "%s-serial.txt" % vm_name)
              FileUtils.touch(serialFile)

              config.vm.provider :vmware_fusion do |v, override|
                v.vmx["serial0.present"] = "TRUE"
                v.vmx["serial0.fileType"] = "file"
                v.vmx["serial0.fileName"] = serialFile
                v.vmx["serial0.tryNoRxLoss"] = "FALSE"
              end

              config.vm.provider :virtualbox do |vb, override|
                vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
                vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
              end
            end

            # Forward docker tcp
            if $expose_docker_tcp
              config.vm.network "forwarded_port", guest: 2375, host: ($expose_docker_tcp + i - 1), auto_correct: true
            end

            # Script for removing all the containers
            $scriptRemoveAllContainers = <<-'EOF'
            if [ `docker ps --no-trunc -aq | wc -l` -gt 0 ]
                then
                echo "Removing Old Containers"
                docker stop `docker ps --no-trunc -aq`
                docker rm `docker ps --no-trunc -aq`
            fi
            EOF

            # Remove all containers before provisioning them
            node_config.vm.provision :shell, :inline => $scriptRemoveAllContainers

            # Remove all service files before provisioning them
            node_config.vm.provision :shell, :inline => "if [ -d \"/etc/systemd/system/multi-user.target.wants\" ]; then rm -r /etc/systemd/system/multi-user.target.wants; fi"

            # Run the containers from the config above
            dockerContainers.each do |container|
                node_config.vm.provision :shell, :inline => "sh /home/core/share/install.sh '#{container[:name]}' '#{container[:ports]}' '#{container[:environment]}' '#{container[:start_shell]}' '#{container[:required_dir]}' '#{container[:shared_dir]}'"
            end
        end
    end
end

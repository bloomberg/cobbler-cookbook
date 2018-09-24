Vagrant.configure('2') do |config|
  config.vm.box = ENV.fetch('VAGRANT_BOX_NAME', 'ubuntu/trusty64')

  config.omnibus.chef_version = :latest if Vagrant.has_plugin?('vagrant-omnibus')
  config.berkshelf.enabled = true if Vagrant.has_plugin?('vagrant-berkshelf')

  config.vm.define :cobbler, primary: true do |guest|
    guest.vm.network :forwarded_port, guest: 80, host: 8080
    guest.vm.provision :chef_solo do |chef|
      chef.run_list = ['cobblerd::web', 'cobblerd::ubuntu']
    end
  end
end

require 'spec_helper'

describe_recipe 'cobblerd::source' do
  %w{pyflakes
     pep8
     python-sphinx
     python-cheetah
     python-yaml
     python-nose
     debhelper}.each do |pkg|
    it { expect(chef_run).to install_package(pkg) }
  end
  it { expect(chef_run).to sync_git("#{Chef::Config[:file_cache_path]}/cobbler") }
  it { expect(chef_run).not_to run_bash('compile cobbler') }
  it { expect(chef_run).to run_bash('cleanup') }
end

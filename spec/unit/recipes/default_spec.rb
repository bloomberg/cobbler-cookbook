require 'spec_helper'

describe_recipe 'cobblerd::default' do
  it { expect(chef_run).to include_recipe('apt::default') }
  it { expect(chef_run).not_to include_recipe('yum-epel::default') }
  it { expect(chef_run).to install_package('cobbler') }
  it { expect(chef_run).to enable_service('cobbler') }
  it { expect(chef_run).to start_service('cobbler') }
end

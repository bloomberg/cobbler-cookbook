require 'spec_helper'

describe_recipe 'cobblerd::web' do
  it { expect(chef_run).to include_recipe('cobblerd::default') }
  it { expect(chef_run).to install_package('cobbler-web') }
  it { expect(chef_run).to run_ruby_block('Write /etc/cobbler/users.digest') }
end

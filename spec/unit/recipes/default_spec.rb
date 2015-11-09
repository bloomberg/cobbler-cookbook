require 'spec_helper'

describe_recipe 'cobblerd::default' do
  it { expect(chef_run).to enable_service('cobbler') }
  it { expect(chef_run).to start_service('cobbler') }
  it { expect(chef_run).not_to run_bash('cobbler sync') }
end

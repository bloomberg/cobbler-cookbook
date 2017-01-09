require 'spec_helper'

describe package('cobbler') do
  it { should be_installed }
end

describe service('cobblerd') do
  it { should be_running }
end

describe file('/var/lib/cobbler/kickstarts/chef-ubuntu.ks') do
  it { should be_file }
  it { should contain('cloud').after(%r(^d-i passwd/username)) }
  it { should contain('900').after(%r(^d-i passwd/user-uid)) }
  it { should contain('ca3c57').after(%r(^d-i passwd/user-password-crypted)) }
  it { should contain('21e1bc').after(%r(^d-i passwd/root-password-crypted)) }
end

describe file('/var/lib/cobbler/kickstarts/chef-redhat.ks') do
  it { should be_file }
  it { should contain('cloud').after('--name') }
  it { should contain('900').after('--uid') }
  it { should contain('ca3c57').after('--iscrypted --password') }
  it { should contain('21e1bc').after(%r(^rootpw)) }
end

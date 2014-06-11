require 'spec_helper'

describe package('cobbler-web') do
  it { should be_installed }
end

describe package('apache2') do
  it { should be_installed }
end

describe port(80) do
  it { should be_listening.with('tcp') }
end

process_name = 'httpd'
process_name = 'apache2' if os[:family] == 'Ubuntu'

describe service(process_name) do
  it { should be_running }
  it { should be_enabled }
end

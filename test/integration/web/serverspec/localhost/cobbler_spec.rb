require 'spec_helper'

describe package('cobbler-web') do
  it { should be_installed }
  it { should be_enabled }
end

require 'spec_helper'

describe package('cobbler') do
  it { should be_installed }
end

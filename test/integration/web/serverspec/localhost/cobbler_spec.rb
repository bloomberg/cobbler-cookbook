require 'spec_helper'

describe package('cobbler-web') do
  it { should be_installed }
end

#
# Cookbook:: cobblerd
# Spec:: server
#
# Copyright:: 2017, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'cobblerd::server' do
  let(:packages) do
    %w[cobbler cobbler-web]
  end
  platforms.each do |platform, details|
    versions = details['versions']
    versions.each do |version|
      context "On #{platform} #{version}" do
        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: platform, version: version)
          runner.node.override['environment'] = 'dev'
          runner.converge(described_recipe)
        end

        it 'should install the required packages' do
          packages.each do |pkg|
            expect(chef_run).to install_package(pkg)
          end
        end

        it 'should configure Cobbler' do
          expect(chef_run).to create_template('/etc/cobbler/auth.conf')
          expect(chef_run).to create_template('/etc/cobbler/settings')
          expect(chef_run).to create_template('/etc/cobbler/modules.conf')
          expect(chef_run).to create_template('/etc/cobbler/users.conf')
        end

        it 'should enable and start the Cobbler services' do
          expect(chef_run).to enable_service('cobblerd')
          expect(chef_run).to start_service('cobblerd')
        end
      end
    end
  end
end

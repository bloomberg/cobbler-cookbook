#
# Cookbook:: psmc_cobbler
# Spec:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'cobblerd::default' do
  let(:recipes) do
    %w[cobblerd::repos cobblerd::server cobblerd::nginx cobblerd:uwsgi]
  end

  platforms.each do |platform, details|
    versions = details['versions']
    versions.each do |version|
      context "On #{platform} #{version}" do
        before do
          recipes.each do |recipe|
            allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).with(recipe)
          end
        end

        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: platform, version: version)
          runner.node.override['environment'] = 'dev'
          runner.converge(described_recipe)
        end

        it 'should define the cobbler-sync command' do
          resource = chef_run.bash('cobbler-sync')
          expect(resource).to do_nothing
        end

        it 'should require the other recipes' do
          recipes.each do |recipe|
            expect_any_instance_of(Chef::Recipe).to receive(:include_recipe).with(recipe)
          end
          chef_run
        end
      end
    end
  end
end

#
# Cookbook:: psmc_cobbler
# Spec:: nginx
#
# Copyright:: 2017, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'cobblerd::nginx' do
  let(:recipes) do
    %w[nginx nginx::http_stub_status_module nginx::http_realip_module]
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
          runner.node.override['psmc_cobbler']['http']['dhparams_file'] = '/etc/dhparams.pem'
          runner.converge(described_recipe)
        end

        it 'should require the other recipes' do
          recipes.each do |recipe|
            expect_any_instance_of(Chef::Recipe).to receive(:include_recipe).with(recipe)
          end
          chef_run
        end

        it 'should create the DHPARAMS file' do
          expect(chef_run).to create_dhparam_pem('/etc/dhparams.pem')
        end

        it 'should create and enable the Nginx sites' do
          expect(chef_run).to create_template('/etc/nginx/sites-available/localhost')
          resource = chef_run.template('/etc/nginx/sites-available/localhost')
          expect(resource).to notify('service[nginx]')
          expect(chef_run).to enable_nginx_site('localhost')

          expect(chef_run).to create_template('/etc/nginx/sites-available/localhost-ssl')
          resource = chef_run.template('/etc/nginx/sites-available/localhost-ssl')
          expect(resource).to notify('service[nginx]')
          expect(chef_run).to enable_nginx_site('localhost-ssl')
        end

        it 'should enable and start Nginx' do
          expect(chef_run).to enable_service('nginx')
          expect(chef_run).to start_service('nginx')
        end
      end
    end
  end
end

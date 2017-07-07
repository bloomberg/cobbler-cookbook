require 'spec_helper'

describe 'cobblerd_test::delete_distros' do
  include_context 'recipe variables'
  platforms.each do |platform, details|
    versions = details['versions']
    versions.each do |version|
      # TODO: Tests required: delete existing, attempt to delete non-existant, attempt to delete existing with deps.
      # TODO: To test existing, need to stub the @current_resource load.
      # TODO: To test existing, need to stub the cobbler find / cobbler list command.
      context "On #{platform} #{version} when the distro does NOT exist" do
        let(:shellout) do
          # stdout should return nothing, indicating there is no matching distro, thus it does not exist
           double(run_command: nil, error!: nil, stdout: '', stderr: double(empty?: true))
         end

        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: platform, version: version, step_into: ['cobblerd_distro'])
          runner.node.override['environment'] = 'dev'
          runner.converge(described_recipe)
        end

        before do
          Mixlib::ShellOut.stub(:new).and_return(shellout)
        end

        it 'should run the "cobbler remove" statement' do
          expect(chef_run).to delete_cobblerd_distro("centos-existing")
          expect(chef_run).to_not run_bash("centos-non-existant-cobbler-distro-remove")
        end
      end

      context "On #{platform} #{version} when the distro does exist" do
        let(:shellout) do
           double(run_command: nil, error!: nil, stdout: 'centos-existing', stderr: double(empty?: true))
         end

        let(:chef_run) do
          runner = ChefSpec::SoloRunner.new(platform: platform, version: version, step_into: ['cobblerd_distro'])
          runner.node.override['environment'] = 'dev'
          runner.converge(described_recipe)
        end

        before do
          Mixlib::ShellOut.stub(:new).and_return(shellout)
        end

        it 'should run the "cobbler remove" statement' do
          expect(chef_run).to delete_cobblerd_distro("centos-existing")

          command =  "        cobbler distro remove --name=centos-existing\n"
          expect(chef_run).to run_bash("centos-existing-cobbler-distro-remove").with(code: command)
        end
      end
    end
  end
end

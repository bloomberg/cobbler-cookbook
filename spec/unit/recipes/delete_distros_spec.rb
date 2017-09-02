require 'spec_helper'

describe 'cobblerd_test::delete_distros' do
  include_context 'recipe variables'
  platforms.each do |platform, details|
    versions = details['versions']
    versions.each do |version|
      # TODO: Tests required: delete existing, attempt to delete non-existant, attempt to delete existing with deps.
      # TODO: To test existing, need to stub the @current_resource load.
      # TODO: To test existing, need to stub the cobbler find / cobbler list command.
      let(:distro_exists) do
        double(run_command: nil, error?: false, exitstatus: 0, stdout: 'centos-existing', stderr: '')
      end

      let(:distro_report) do
        stdout_text = <<-eos.gsub /^\s+/, ''
          Name                           : centos-existing
          Architecture                   : x86_64
          TFTP Boot Files                : {}
          Breed                          : redhat
          Comment                        :
          Fetchable Files                : {}
          Initrd                         : /var/www/cobbler/images/centos-existing/isolinux/initrd.img
          Kernel                         : /var/www/cobbler/images/centos-existing/isolinux/vmlinuz
          Kernel Options                 : {}
          Kernel Options (Post Install)  : {}
          Kickstart Metadata             : {'tree': 'http://@@http_server@@/cblr/links/centos-existing'}
          Management Classes             : []
          OS Version                     : rhel7
          Owners                         : ['admin']
          Red Hat Management Key         : <<inherit>>
          Red Hat Management Server      : <<inherit>>
          Template Files                 : {}
        eos
        double(run_command: nil, error?: false, exitstatus: 0, stdout: stdout_text, stderr: '')
      end

      let(:distro_missing) do
        double(run_command: nil, error?: false, exitstatus: -1, stdout: '', stderr: '')
      end

      let(:chef_run) do
        runner = ChefSpec::SoloRunner.new(platform: platform, version: version, step_into: ['cobblerd_distro'])
        runner.node.override['environment'] = 'dev'
        runner.converge(described_recipe)
      end

      before do
        allow(Mixlib::ShellOut).to receive(:new).and_call_original
        allow(Mixlib::ShellOut).to receive(:new)
          .with('cobbler distro find --name=centos-non-existant | grep \'centos-non-existant\'')
          .and_return(distro_missing)

        allow(Mixlib::ShellOut).to receive(:new)
          .with('cobbler distro report --name=\'centos-existing\'')
          .and_return(distro_report)

        allow(Mixlib::ShellOut).to receive(:new)
          .with('cobbler distro find --name=centos-existing | grep \'centos-existing\'')
          .and_return(distro_exists)
      end

      context "On #{platform} #{version} when the distro does NOT exist" do
        it 'should run the "cobbler remove" statement' do
          expect(chef_run).to delete_cobblerd_distro("centos-non-existant")
          expect(chef_run).to_not run_bash("centos-non-existant-cobbler-distro-remove")
        end
      end

      context "On #{platform} #{version} when the distro does exist" do
        it 'should run the "cobbler remove" statement' do
          expect(chef_run).to delete_cobblerd_distro("centos-existing")

          command =  "        cobbler distro remove --name=centos-existing\n"
          expect(chef_run).to run_bash("centos-existing-cobbler-distro-remove").with(code: command)
        end
      end
    end
  end
end

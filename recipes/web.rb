#
# Cookbook Name:: cobblerd
# Recipe:: web
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#

include_recipe 'cobblerd::default'

if node[:platform_family] == 'rhel'
  return unless node[:platform_version].to_f > 5
  include_recipe 'yum-epel::default'
end

package 'cobbler-web'

# Write out a password digest file for the cobbler web user. It would
# normally use the `htdigest` command but luckily Ruby has it built in.
ruby_block 'Write /etc/cobbler/users.digest' do
  block do
    require 'webrick'
    file = ::WEBrick::HTTPAuth::Htdigest.new '/etc/cobbler/users.digest'
    file.set_passwd 'Cobbler', node[:cobblerd][:web_username],
                               node[:cobblerd][:web_password]
    file.flush
  end
  notifies :restart, 'service[cobbler]', :delayed
end

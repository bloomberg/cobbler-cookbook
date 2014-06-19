#
# Cookbook Name:: cobblerd
# Recipe:: web
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#

include_recipe 'cobblerd::default'

if rhel?
  return unless node[:platform_version].to_f > 5
  include_recipe 'yum-epel::default'
end

package 'cobbler-web'

# Write out a password digest file for the cobbler web user. It would
# normally use the `htdigest` command but luckily Ruby has it built in.
ruby_block 'Write /etc/cobbler/users.digest' do
  block do
    require 'webrick'
    htpasswd = ::WEBrick::HTTPAuth::Htpasswd.new('/etc/cobbler/users.digest')
    htpasswd.auth_type = WEBrick::HTTPAuth::DigestAuth
    htpasswd.set_passwd 'Cobbler', node[:cobbler][:web_username], node[:cobbler][:web_password]
    htpasswd.flush
  end
  notifies :restart, 'service[apache2]', :delayed
end

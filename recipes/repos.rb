#
# Cookbook Name:: cobblerd
# Recipe:: repos
#
# Copyright:: 2017, Justin Spies, All Rights Reserved
#
include_recipe 'yum-epel::default' if node['platform_family'] == 'rhel'
include_recipe 'apt::default' if node['platform_family'] == 'debian'

if node['platform'] =~ /oracle/ && node['platform_version'] =~ /^7/
  # Deleting because it conflicts with Chef setting up the other repositories and causes errors about the
  # same repo defined twice.
  file '/etc/yum.repos.d/public-yum-ol7.repo' do
    action :delete
  end

  # Only needed for RHEL 7 / Oracle 7 but not CentOS.
  yum_repository 'ol7_base_latest' do
    description 'Oracle Linux $releasever Base Latest ($basearch)'
    baseurl 'http://yum.oracle.com/repo/OracleLinux/OL7/latest/$basearch/'
    gpgkey 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle'
    gpgcheck true
    action :create
  end

  # Required so that python-cheetah / python-pygments installs successfully. CentOS automatically provides
  # access to python-pygments while RHEL and Oracle put it into the 'optional' repo which is disabled by default
  # Only needed for RHEL 7 / Oracle 7 but not CentOS.
  yum_repository 'ol7_optional_latest' do
    description 'Oracle Linux $releasever Optional Latest ($basearch)'
    baseurl 'http://yum.oracle.com/repo/OracleLinux/OL7/optional/latest/$basearch/'
    gpgkey 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle'
    gpgcheck true
    action :create
  end
end

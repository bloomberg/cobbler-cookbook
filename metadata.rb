name             'cobblerd'
maintainer       'Compute Architecture'
maintainer_email 'compute@bloomberg.net'
license          'Apache 2.0'
description      'Installs/Configures cobblerd'
long_description 'Installs/Configures cobblerd'
version          '0.5.0'
# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
issues_url 'https://github.com/eyespies/cobbler-cookbook/issues' if respond_to?(:issues_url)

# The `source_url` points to the development reposiory for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
source_url 'https://github.com/eyespies/cobbler-cookbook' if respond_to?(:source_url)

depends 'apt'
# For RHEL 7 and later platforms
depends 'nginx', '~> 7.0.0'
# Used to generate dhparams.pem
depends 'openssl', '~> 7.1.0'
depends 'poise'
depends 'yum-epel'

%w[centos redhat].each do |name|
  supports name, '~> 6.0'
  supports name, '~> 7.0'
end

%w[12.04 14.04].each do |vers|
  supports 'ubuntu', "= #{vers}"
end

chef_version '>= 12' if respond_to?(:chef_version)

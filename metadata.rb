name             'cobblerd'
maintainer       'Compute Architecture'
maintainer_email 'compute@bloomberg.net'
license          'Apache 2.0'
description      'Installs/Configures cobblerd'
long_description 'Installs/Configures cobblerd'
version          '0.4.0'
# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
issues_url 'https://github.com/bloomberg/cobbler-cookbook/issues' if respond_to?(:issues_url)

# The `source_url` points to the development reposiory for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
source_url 'https://github.com/eyespies/cobbler-cookbook' if respond_to?(:source_url)

%w(centos redhat).each do |name|
  supports name, '~> 6.5'
  supports name, '~> 5.10'
  supports name, '~> 7.0'
end

supports 'ubuntu', '= 12.04'
supports 'ubuntu', '= 14.04'

depends 'poise'
depends 'apt'
depends 'yum-epel'

chef_version '>= 11' if respond_to?(:chef_version)

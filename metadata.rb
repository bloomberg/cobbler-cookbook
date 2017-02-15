name             'cobblerd'
maintainer       'Compute Architecture'
maintainer_email 'compute@bloomberg.net'
license          'Apache 2.0'
description      'Installs/Configures cobblerd'
long_description 'Installs/Configures cobblerd'
version          '0.4.0'

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

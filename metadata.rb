name             'cobblerd'
maintainer       'John Bellone'
maintainer_email 'jbellone@bloomberg.net'
license          'Apache 2.0'
description      'Installs/Configures cobbler'
long_description 'Installs/Configures cobbler'
version          '0.1.0'

%w(centos redhat).each do |name|
  supports name, '~> 6.5'
  supports name, '~> 5.10'
  supports name, '~> 7.0'
end

supports 'ubuntu', '= 12.04'
supports 'ubuntu', '= 14.04'

depends 'apt'
depends 'chef-sugar'
depends 'yum-epel'

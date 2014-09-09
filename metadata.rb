name             'cobblerd'
maintainer       'John Bellone'
maintainer_email 'jbellone@bloomberg.net'
license          'Apache 2.0'
description      'Installs/Configures cobblerd'
long_description 'Installs/Configures cobblerd'
version          '0.3.0'

%w(centos redhat).each do |name|
  supports name, '~> 6.5'
  supports name, '~> 5.10'
  supports name, '~> 7.0'
end

supports 'ubuntu', '= 12.04'
supports 'ubuntu', '= 14.04'

depends 'poise', '~> 1.0'
recommends 'apt', '~> 2.4'
recommends 'yum-epel', '~> 0.3'

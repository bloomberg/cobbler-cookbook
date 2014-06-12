#
# Cookbook Name:: cobblerd
# Attribute:: default
#
# Copyright (C) 2014 Bloomberg Finance L.P.
#

# echo 'root' | shasum -a 512 -p
default[:cobbler][:root_password] = '21e1bc024bd76c76b68e04614c6def5b03fd4b658e59bfde065b464b520f463711b795455e3a5c81a8a1946b2bca2f83d6c19300a4d3326ce17959a7cbc0846a'
default[:cobbler][:use_cookbook_kickstarts] = true

# echo 'cloud' | shasum -a 512 -p
default[:cobbler][:user][:password] = 'ca3c5707906acf7fd41e194b33fea5e1481305016538af1b1294d6dcd6016b5dea13adb5b01584c54a8b4e3121523eaf4347d9c5be7475438bcc3cb01a91740f'
default[:cobbler][:user][:name] = 'cloud'
default[:cobbler][:user][:uid] = 900

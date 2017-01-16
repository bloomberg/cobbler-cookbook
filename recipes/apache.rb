# we can not enable both python and wsgi
# ensure python is disabled (i.e. override Ubuntu 16.04 default)
apache_module 'python' do
  enable false
end

include_recipe 'apache2'
include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'

apache_module 'wsgi'

web_app "cobbler" do
  template "cobbler.conf.erb"
end

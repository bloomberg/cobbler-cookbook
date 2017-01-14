include_recipe 'apache2'
include_recipe 'apache2::mod_proxy'
include_recipe 'apache2::mod_proxy_http'

apache_module 'wsgi'

web_app "cobbler" do
  template "cobbler.conf.erb"
end

service 'httpd' do
  action [:enable, :start]
end

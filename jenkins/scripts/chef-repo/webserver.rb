#
# Cookbook:: nginx_setup
# Recipe:: webserver.rb
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#
yum_package 'nginx' do
  action :install
end

service 'nginx' do
  supports status: true
  action :start
end

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
end

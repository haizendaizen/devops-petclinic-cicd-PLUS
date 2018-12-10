#
# Cookbook:: learn_chef_nginx
# Recipe:: default
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

template '/usr/share/nginx/html/index.html' do
  source 'index.html.erb'
end

#
# Cookbook:: hello_world!
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
end

service 'nginx' do
  supports status: true
  action :start
end

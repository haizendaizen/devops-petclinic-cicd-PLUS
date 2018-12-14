#
# Cookbook:: hello_world!
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

file '/home/ec2-user/hello.txt' do
  content 'Welcome to Chef'
end

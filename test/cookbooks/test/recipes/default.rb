
windows_route '10.0.1.11/32' do
  gateway '0.0.0.0'
  interface_alias node['if_name']
  comment 'a comment!'
  persistent false
end

windows_route '10.3.1.12/32' do
  gateway '0.0.0.0'
  metric 200
  device node['if_name']
end

windows_route '10.3.1.12/32' do
  gateway '0.0.0.2'
  device node['if_name']
end

windows_route '10.2.1.10/32' do
  gateway '0.0.0.0'
  action :add
end

# windows_route '2001:0db8:85a3:0000:0000:8a2e:0370:7334' do
#     gateway '0.0.0.0'
#     action :add
# end

windows_route '10.2.1.10/32' do
  gateway '0.0.0.0'
  action :delete
end

windows_route '10.2.1.10/32' do
  gateway '0.0.0.0'
  action :delete
end

windows_route '10.4.0.1/32' do
  netmask '255.255.0.0'
  gateway '0.0.0.0'
  action :add
end

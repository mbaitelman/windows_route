
windows_route '10.0.1.11/32' do
    gateway '0.0.0.0'
    device 'eth0'
end

windows_route '10.3.1.12/32' do
    gateway '0.0.0.1'
    device 'eth0'
end

windows_route '10.3.1.12/32' do
    gateway '0.0.0.2'
    device 'eth0'
end

windows_route '10.2.1.10/32' do
    gateway '0.0.0.0'
    action :add
end

windows_route '10.2.1.10/32' do
    gateway '0.0.0.0'
    action :delete
end

windows_route '10.2.1.10/32' do
    gateway '0.0.0.0'
    action :delete
end

windows_route '11.0.0.0' do 
    netmask '255.255.0.0'
    gateway '192.168.51.221'
    action :add
end
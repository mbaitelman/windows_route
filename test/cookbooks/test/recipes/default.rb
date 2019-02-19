
windows_route '10.0.1.10/32' do
    gateway '0.0.0.0'
    device 'eth0'
end

windows_route '10.0.1.10/32' do
    gateway '0.0.0.0'
    action :delete
end
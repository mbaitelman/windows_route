# # encoding: utf-8

# Inspec test for recipe windows_route::default

# describe powershell('(Get-NetRoute -AddressFamily IPv4 -DestinationPrefix 10.0.1.11/32).state') do
#   its('stderr') { should cmp('Alive') }
#   its('exit_status') { should eq 0 }
#   its('stdout') { should cmp('Alive') }
# end

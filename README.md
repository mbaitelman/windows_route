# windows_route Cookbook

The windows_route resource configures routes on Windows hosts by running the *-NetRoute suite of Powershell commands.

## Requirements

### Platforms

- Windows 8, 8.1, 10
- Windows Server 2012 (R1, R2)
- Windows Server 2016
- Windows Server 2019

### Chef

- Chef 13.9+

## Resources

### windows_route

#### Actions

- `:add` - creates a Windows route
- `:delete` - deletes a Windows route

#### properties

- `target`: CIDR of the IP address of the target. (Name property)
- `metric`: An integer value which will be used to decide which route will be used, the system will use the lowest value.
- `gateway`: The gateway for the route.
- `device`: The Interface Alias to use. If a value is not given it will pull the first device. Can also be called with `interface_alias`
- `persistent`: Whether or not the route should persist after reboots. defualt: true.

There are a few attributes that are supported in the [linux route resource](https://docs.chef.io/resource_route.html) and are accepted here and will warn when used. See `:comment`, `:netmask` and `:route_type`

#### Examples

```ruby
    windows_route 'Adds a route for 10.0.1.11/32 via 0.0.0.0 over Ethernet' do
        target  '10.0.1.11/32'
        gateway '0.0.0.0'
        device  'Ethernet' 
        metric  200
    end
```

```ruby
  windows_route '10.0.1.11/32' do
    action delete
  end
```

## License & Authors

- Author:: Mendy Baitelman (mendy@baitelman.com)

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
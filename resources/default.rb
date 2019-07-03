# resource_name :windows_route

# provides :windows_route

# default_action :add
# allowed_actions :add, :delete

description 'Use the route resource to manage the system routing table in a Windows environment.'

property :target, String,
          description: 'The IP address of the target route.',
          identity: true, name_property: true

property :comment, [String, nil],
          description: 'Add a comment for the route. Not supported in windows_route.'

property :metric, [Integer, nil],
          description: 'The route metric value.'

property :netmask, [String, nil],
          description: 'The decimal representation of the network mask. For example: 255.255.255.0.'

property :gateway, [String, nil],
          description: 'The gateway for the route.'

property :device, [String, nil],
          description: 'The network interface to which the route applies.', # Has a partial default in the action to get the first interface.
          default: nil

property :route_type, [Symbol, String, nil],
          description: '',
          equal_to: [:host, :net],
          default: nil

property :persistent, [TrueClass, FalseClass],
          default: true

alias_method :interface_alias, :device

action :add do
  description ''
  validate_attributes

  code_script = 'New-NetRoute -AddressFamily IPv4 '
  code_script << " -DestinationPrefix #{new_resource.target}"
  code_script << " -RouteMetric #{new_resource.metric}" if new_resource.metric
  code_script << " -NextHop #{new_resource.gateway}" if new_resource.gateway
  ifalias = if new_resource.device.nil?
              powershell_out!('((Get-NetIPInterface -AddressFamily IPv4)[0].ifAlias)').stdout.strip
            else
              new_resource.device
            end
  code_script << " -InterfaceAlias '#{ifalias}'"
  code_script << ' -PolicyStore ActiveStore' unless new_resource.persistent

  guard_script = create_guard_script

  powershell_script "setting route on #{new_resource.target} using (#{code_script})" do
    code code_script
    not_if guard_script # Always add unless it already exists
  end
end

action :delete do
  description ''
  validate_attributes
  code_script = "Remove-NetRoute -DestinationPrefix #{new_resource.target} -Confirm:$false"
  guard_script = create_guard_script

  powershell_script "Deleting route on #{new_resource.target} using (#{code_script})" do
    code code_script
    only_if guard_script # Only delete if it already exists
  end
end

action_class do
  def validate_attributes
    ipaddr = IPAddr.new new_resource.target
    raise 'IP is not IPv4 compliant' unless ipaddr.ipv4?() # Checks IPv4
    unless new_resource.target.include? '/' # Checks if valid CIDR # TODO fix cidr check
      raise "IP #{new_resource.target} is not a valid CIDR map"
    end
    # Check attributes that exist in the linux version
    unless new_resource.comment.nil? # Checks :comment as not supported
      warn 'The :comment attribute is not supported in the windows_route resource'
    end
    unless new_resource.netmask.nil? # Checks :netmask as not supported # TODO check if it can be supported
      warn 'The :netmask attribute is not supported in the windows_route resource'
    end
    unless new_resource.route_type.nil? # Checks :route_type as not supported # TODO check if it can be supported
      warn 'The :route_type attribute is not supported in the windows_route resource'
    end
  end

  def create_guard_script # Returns script that will respond with a boolean value of whether or not a route exits for the target
    script = '[bool](Get-NetRoute -AddressFamily IPv4'
    script << " -DestinationPrefix #{new_resource.target}"
    script << ' -ErrorAction Ignore)'
    script
  end
end

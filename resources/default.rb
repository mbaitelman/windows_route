# resource_name :windows_route

# provides :windows_route

# default_action :add
# allowed_actions :add, :delete

description "Use the route resource to manage the system routing table in a Linux environment."

property :target, String,
          description: "The IP address of the target route.",
          identity: true, name_property: true

property :comment, [String, nil],
          description: "Add a comment for the route."

property :metric, [Integer, nil],
          description: "The route metric value."

property :netmask, [String, nil],
          description: "The decimal representation of the network mask. For example: 255.255.255.0."

          #Interface?
property :gateway, [String, nil],
          description: "The gateway for the route."

property :device, [String, nil],
          description: "The network interface to which the route applies.",
          desired_state: false # Has a partial default in the provider of eth0.

property :route_type, [Symbol, String],
          description: "",
          equal_to: [:host, :net], default: :host, desired_state: false

action :add do 
  description ''
  validate_attributes
  # route ADD 192.168.35.0 MASK 255.255.255.0 192.168.0.2
  # route ADD destination_network MASK subnet_mask  gateway_ip metric_cost

  code_script = " route -p add"
  code_script << " #{new_resource.target} "
  code_script << " MASK #{new_resource.netmask}" if new_resource.netmask
  code_script << " #{new_resource.gateway}" if new_resource.gateway
  code_script << " #{new_resource.metric}" if new_resource.metric

  guard_script = "[bool](Get-NetRoute -AddressFamily IPv4"
  guard_script << " -DestinationPrefix #{new_resource.target}"
  guard_script << "-ErrorAction Ignore)"

  powershell_script "setting route on #{new_resource.target} using (#{code_script})" do
    guard_interpreter :powershell_script
    convert_boolean_return true
    code code_script
    only_if guard_script
    #sensitive if new_resource.sensitive
  end
end

action :delete do 
  description ''
  code_script = "Remove-NetRoute -DestinationPrefix #{new_resource.target}  -Confirm $false"

  guard_script = "[bool](Get-NetRoute -AddressFamily IPv4"
  guard_script << " -DestinationPrefix #{new_resource.target}"
  guard_script << " -ErrorAction Ignore)"

  powershell_script "Deleting route on #{new_resource.target} using (#{code_script})" do
    guard_interpreter :powershell_script
    convert_boolean_return true
    code code_script
    not_if guard_script
    #sensitive if new_resource.sensitive
  end
end

action_class do
  def validate_attributes 
    ipaddr = IPAddr.new new_resource.target
    if !ipaddr.ipv4?()
      raise 'IP is not IPv4 compliant'
    end
    if new_resource.comment
      raise 'The :comment attribute is not supported in the windows_route resource'
    end
  end
  def guard_script_shared
    script = "[bool](Get-NetRoute -AddressFamily IPv4"
    script << " -DestinationPrefix #{new_resource.target}"
    script << " -ErrorAction Ignore)"
    script
  end  
end

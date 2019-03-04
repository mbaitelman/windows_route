resource_name :windows_route

provides :windows_route

default_action :add
allowed_actions :add, :delete

description "Use the route resource to manage the system routing table in a Linux environment."

property :target, String,
          description: "The IP address of the target route.",
          identity: true, name_property: true

property :comment, [String, nil],
          description: "Add a comment for the route.",
          introduced: "14.0"

property :metric, [Integer, nil],
          description: "The route metric value."

property :netmask, [String, nil],
          description: "The decimal representation of the network mask. For example: 255.255.255.0."

property :gateway, [String, nil],
          description: "The gateway for the route."

property :device, [String, nil],
          description: "The network interface to which the route applies.",
          desired_state: false # Has a partial default in the provider of eth0.

property :route_type, [Symbol, String],
          description: "",
          equal_to: [:host, :net], default: :host, desired_state: false

action :add do
    action_add
end

action :delete do
  action_delete
end


attr_accessor :is_running

MASK = { "0.0.0.0"          => "0",
          "128.0.0.0"        => "1",
          "192.0.0.0"        => "2",
          "224.0.0.0"        => "3",
          "240.0.0.0"        => "4",
          "248.0.0.0"        => "5",
          "252.0.0.0"        => "6",
          "254.0.0.0"        => "7",
          "255.0.0.0"        => "8",
          "255.128.0.0"      => "9",
          "255.192.0.0"      => "10",
          "255.224.0.0"      => "11",
          "255.240.0.0"      => "12",
          "255.248.0.0"      => "13",
          "255.252.0.0"      => "14",
          "255.254.0.0"      => "15",
          "255.255.0.0"      => "16",
          "255.255.128.0"    => "17",
          "255.255.192.0"    => "18",
          "255.255.224.0"    => "19",
          "255.255.240.0"    => "20",
          "255.255.248.0"    => "21",
          "255.255.252.0"    => "22",
          "255.255.254.0"    => "23",
          "255.255.255.0"    => "24",
          "255.255.255.128"  => "25",
          "255.255.255.192"  => "26",
          "255.255.255.224"  => "27",
          "255.255.255.240"  => "28",
          "255.255.255.248"  => "29",
          "255.255.255.252"  => "30",
          "255.255.255.254"  => "31",
          "255.255.255.255"  => "32" }.freeze

def load_current_resource
  self.is_running = false
  Chef::Log.info('running load_current_resource')

  # cidr or quad dot mask
  new_ip = if new_resource.target == "default"
               IPAddr.new(new_resource.gateway)
           elsif new_resource.netmask
             IPAddr.new("#{new_resource.target}/#{new_resource.netmask}")
           else
             IPAddr.new(new_resource.target)
           end

  # Read all routes
  route_table = `route print -4`

  # new_ip = IPAddr.new("127.255.255.255/255.255.255.255")
  # new_resource = 'RESOURCE'
  # new_resourcegateway = 'On-link'    
  route_table = `route print -4`
  route_table.lines("\n").each do | line |
      begin
          route_array = line.gsub(/\s+/m, ' ').strip.split(" ")
          if route_array.length == 5
              #puts "dest: #{route_array[0]}, mask: #{route_array[1]}, gateway: #{route_array[2]}, interface: #{route_array[3]}, metric #{route_array[4]}"
              destination = route_array[0]
              gateway = route_array[2]
              mask = route_array[1]
          else 
              next
          end
      rescue
          next # If line is not a route line continue on
      end
      Chef::Log.info("#{new_resource} system has route: dest=#{destination} mask=#{mask} gw=#{gateway}")
  
      # check if what were trying to configure is already there
      # use an ipaddr object with ip/mask this way we can have
      # a new resource be in cidr format (i don't feel like
      # expanding bitmask by hand.
      #
      running_ip = IPAddr.new("#{destination}/#{mask}")
      Chef::Log.info("#{new_resource} new ip: #{new_ip.inspect} running ip: #{running_ip.inspect}")
      self.is_running = true if running_ip == new_ip && gateway == new_resource.gateway
 end # End route table loop
end

action_class do
  def action_add
    Chef::Log.info('action_add called')
    #check to see if load_current_resource found the route
    if is_running
      Chef::Log.trace("#{new_resource} route already active - nothing to do")
    else
      command = generate_command(:add)
      converge_by("run #{command} to add route") do
          Chef::Log.debug('add called')
          shell_out!(*command)
          Chef::Log.info("#{new_resource} added")
      end
    end
  end

  def action_delete
    if is_running
      command = generate_command(:delete)
      converge_by("run #{command} to delete route ") do
        shell_out!(*command)
        Chef::Log.info("#{new_resource} removed")
      end
    else
      Chef::Log.info("#{new_resource} route does not exist - nothing to do")
    end
  end


  def generate_command(action)
    #ToDo consider CHANGE action? or warn  
    target = new_resource.target
    target = "#{target}/#{MASK[new_resource.netmask.to_s]}" if new_resource.netmask

    case action
    when :add
      command = "route -p ADD #{target}" 
      command << " MASK #{new_resource.netmask} " if new_resource.netmask 
      #ToDo Do we need to use #{MASK[new_resource.netmask.to_s]?
      command << " #{new_resource.gateway} "
      command << " #{new_resource.metric} " if new_resource.metric
    when :delete
      command = "route DELETE #{new_resource.gateway}"
    end
    Chef::Log.info('new command '  + command)
    command
  end
end

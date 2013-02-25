require 'fog'

module AwSec
  class Core
    
    def self.secure(group_names, public_ip, options = {})
      client = AwSec::Core.new
      client.secure(group_names, public_ip, options)
    end
    
    def secure(group_names, public_ip, options = {})
      public_ip = public_ip
      @port = options[:port] || 22
      @region = options[:aws_region] 
      @aws_key = options[:aws_key] 
      @aws_secret = options[:aws_secret] 
      revoke_all = options.has_key?(:revoke_all) ? options[:revoke_all] : true
      wtlist = options[:whitelist] || []
      
      whitelist = []
      public_ip = "#{public_ip}/32" unless public_ip =~  /\//
      wtlist.each do |ip|
        whitelist << "#{ip}/32" unless ip =~  /\//
      end
      
      puts "Connecting AWS..."
      groups = get_groups(group_names)
      groups.each do |group|
        puts "Configuring #{group.name}"
        granted_ips = list_ips(group) || []
        puts "Existing IPs with access to port #{port}: #{granted_ips.join(',')}"
        allowed_ips = granted_ips.select { |i| whitelist.include? i }
        allowed_ips << public_ip
        if revoke_all
          granted_ips.each do |ip|
            unless allowed_ips.include? ip
              puts "Revoking access to #{ip}"
              revoke_access(group, ip)
            end
          end
        end
        granted_ips.uniq!
        allowed_ips.each do |ip|
          puts "Granting access to port #{port} to #{ip}"
          safe_authorize_port(group, ip)
        end
      end
    end
    
    def list_ips(group)
      result = []
    	group.ip_permissions.detect do |ip_permission|
    		result << ip_permission['ipRanges'].collect{ |i| i["cidrIp"] } if ip_permission["toPort"] == port
    	end

      result.flatten!
    end

    def revoke_access(group, ip)
      group.revoke_port_range(port..port, :cidr_ip => ip)
    end
    
    def get_groups(group_names)
      groups = []
      group_names.each do |group_name|
        groups << conn.security_groups.get(group_name)
      end
      
      groups
    end
    
    def safe_authorize_port(group, ip)
    	if group.ip_permissions.nil?
    		authorized = false
    	else
    		authorized = is_authorized?(group, ip)
    	end
    	unless authorized
        begin
          group.authorize_port_range(port..port, :cidr_ip => ip)
        rescue => exc
          puts "Failed #{exc.message}"
        end
    	end
    end
    
    def is_authorized?(group, ip)
    	return group.ip_permissions.detect do |ip_permission|
    		ip_permission['ipRanges'].first && ip_permission['ipRanges'].first['cidrIp'] == ip &&
    			ip_permission['fromPort'] == port &&
    			ip_permission['ipProtocol'] == 'tcp' &&
    			ip_permission['toPort'] == port
    	end
    end
    
    def port
      @port
    end
    
    def conn
      @conn ||= Fog::Compute.new({
        :provider => 'AWS',
      	:region => @region,
      	:aws_access_key_id => @aws_key,
      	:aws_secret_access_key => @aws_secret
      	})
    end
    
  end
end
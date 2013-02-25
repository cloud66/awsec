require 'net/http'
require 'highline/import'

module AwSec
  module Providers
    class MyIp
      
      Register.register('My IP', AwSec::Providers::MyIp.new())
      
      def get_public_ip(options)
      	Net::HTTP.get(URI "http://auto.whatismyip.com/ip.php?user=#{options[:my_ip_username]}&password=#{options[:my_ip_password]}")
      end
      
      def configure
        result = {}
        result[:my_ip_username] = ask('My IP username')
        result[:my_ip_password] = ask('My IP password') { |q| q.echo = "*" }
        
        result
      end

    end
  end
end
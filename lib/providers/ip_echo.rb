require 'net/http'

module AwSec
  module Providers
    class EchoIp
      
      Register.register('Echo IP', AwSec::Providers::EchoIp.new())
      
      def get_public_ip(options)
        Net::HTTP.get(URI "http://ipecho.net/plain")
      end
      
       def configure
       end
       
    end
  end
end
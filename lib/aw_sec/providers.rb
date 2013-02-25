module AwSec
  module Providers
    class Register

      def self.register(name, klass)
        @register ||= []
        @register << { :name => name, :class => klass }
      end
      
      def self.list
        @register
      end
      
      def self.provider(provider_name)
        puts "Configuring #{provider_name}"
        klass = Kernel.const_get(provider_name)
        klass.new
      end

      Dir.foreach(File.join(File.dirname(__FILE__), '..', 'providers')) do |file|
        path = File.join(File.join(File.dirname(__FILE__), '..', 'providers', file))
        unless File.directory? path
          require path
        end
      end
      
    end
  end
end
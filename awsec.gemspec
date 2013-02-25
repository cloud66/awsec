require 'rake'
require File.expand_path('lib/version')

Gem::Specification.new do |gem|
  gem.name        = 'awsec'
  gem.version     = AwSec::Version.current
  gem.platform    = Gem::Platform::RUBY
  gem.date        = '2013-02-25'
  gem.summary     = "AWS Security Toolbelt"
  gem.description = "Open and close AWS Security Group from the terminal for more secure operations"
  gem.authors     = ["Cloud 66"]
  gem.email       = 'khash@cloud66.com'
  gem.files       = FileList["lib/version.rb", "lib/aw_sec.rb", 'lib/aw_sec/**/*.rb', 'lib/providers/**/*.rb'].to_a
  gem.add_dependency('json', '>= 1.6.3')
  gem.add_dependency('fog', '>= 1.4.0')
  gem.add_dependency('highline', '>= 1.6.11')
  gem.homepage    = 'https://github.com/cloud66/awsec'
  gem.executables << 'awsec'
  gem.default_executable = 'awsec'
end
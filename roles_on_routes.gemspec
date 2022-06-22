$:.push File.expand_path('../lib', __FILE__)
require 'roles_on_routes/version'

Gem::Specification.new do |s|
  s.name        = 'roles_on_routes'
  s.version     = RolesOnRoutes::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Navigating Cancer']
  s.summary     = 'Define your authorization roles on the routes they apply to'
  s.description = %q{ }
  s.add_dependency 'rails', '>= 3.2', '< 4.1'
  s.add_dependency 'rack'
  s.required_ruby_version = '>= 2.3.8'

  #s.files         = `git ls-files`.split("\n")
  #s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  #s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end

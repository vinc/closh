lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "closh/version"

Gem::Specification.new do |s|
  s.name        = "closh"
  s.version     = CloudShell::VERSION
  s.license     = "MIT"
  s.summary     = "A shell running in the cloud"
  s.description = "Closh automatically bootstrap servers in the cloud to run shell commands"
  s.homepage    = "https://github.com/vinc/closh"
  s.email       = "v@vinc.cc"
  s.authors     = ["Vincent Ollivier"]
  s.files       = Dir.glob("{bin,lib}/**/*") + %w[LICENSE README.md]
  s.executables = %w[closh]
  s.add_runtime_dependency("activesupport", "~> 5.2", ">= 5.2.0")
  s.add_runtime_dependency("fog",           "~> 2.0", ">= 2.0.0")
  s.add_runtime_dependency("net-ssh",       "~> 5.0", ">= 5.0.1")
  s.add_runtime_dependency("rainbow",       "~> 3.0", ">= 3.0.0")
  s.add_runtime_dependency("trollop",       "~> 2.1", ">= 2.1.3")
  s.add_development_dependency("rspec",     "~> 3.7", ">= 3.7.0")
end

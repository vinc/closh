lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "closh/version"

Gem::Specification.new do |s|
  s.name        = "closh"
  s.version     = CloudShell::VERSION
  s.license     = "MIT"
  s.summary     = "A shell running in the cloud"
  s.description = "Run shell commands in the cloud"
  s.homepage    = "https://github.com/vinc/closh"
  s.email       = "v@vinc.cc"
  s.authors     = ["Vincent Ollivier"]
  s.files       = Dir.glob("{bin,lib}/**/*") + %w[LICENSE README.md]
  s.executables = %w[closh]
  s.add_runtime_dependency("activesupport",    "~> 5.1",  ">= 5.1.0")
  s.add_runtime_dependency("fog",              "~> 1.42", ">= 1.42.0")
  s.add_runtime_dependency("net-ssh",          "~> 4.1",  ">= 4.1.0")
  s.add_runtime_dependency("rainbow",          "~> 2.2",  ">= 2.2.0")
  s.add_runtime_dependency("trollop",          "~> 2.1",  ">= 2.1.0")
  s.add_development_dependency("rspec",        "~> 3.6",  ">= 3.6.0")
end

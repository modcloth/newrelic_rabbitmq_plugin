# coding: utf-8
Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '2.2.2'
  s.required_ruby_version = '>= 1.9.3'

  s.name              = 'newrelic_rabbitmq_plugin'
  s.version           = File.read('./VERSION').chomp
  s.license           = 'MIT'

  s.summary     = "New Relic plugin for reporting RabbitMQ statistics"
  s.description = "New Relic plugin for reporting RabbitMQ statistics"

  s.authors  = ["Jesse Szwedko"]
  s.email    = 'j.szwedko@modcloth.com'
  s.homepage = 'https://github.com/modcloth/newrelic_rabbitmq_plugin'

  all_files       = `git ls-files -z`.split("\x0")
  s.files         = all_files.grep(%r{^(bin|lib)/})
  s.executables   = all_files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.rdoc_options = ["--charset=UTF-8"]

  s.add_runtime_dependency('faraday',    "~> 0.9.0")
  s.add_runtime_dependency('faraday_middleware',  "~> 0.9.1")
  s.add_runtime_dependency('newrelic_plugin', "~> 1.3.1")
end

# -*- encoding: utf-8 -*-

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-flow/version'

Gem::Specification.new do |s|
  s.name = "vagrant-flow"
  s.version = VagrantPlugins::VagrantFlow::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Steve Morin"]
  s.date = "2014-02-23"
  s.summary = %q{Enables Vagrant to Generate Ansible Inventory Files.}
  s.description = s.summary
  s.email = "steve@stevemorin.com"
  s.homepage = "http://github.com/DemandCube/vagrant-flow"
  s.licenses = ["AGPL"]

  s.rubyforge_project = "vagrant-flow"
  s.rubygems_version = "2.0.14"

  
  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 1.5"
  s.add_development_dependency "rake"
end

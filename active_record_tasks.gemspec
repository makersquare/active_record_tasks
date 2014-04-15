# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record_tasks/version'

Gem::Specification.new do |spec|
  spec.name          = "active_record_tasks"
  spec.version       = ActiveRecordTasks::VERSION
  spec.authors       = ["Gilbert"]
  spec.email         = ["gilbertbgarza@gmail.com"]
  spec.description   = %q{Use ActiveRecord 4 in non-rails projects.}
  spec.summary       = %q{The easiest way to get started with ActiveRecord 4 in a non-rails project.}
  spec.homepage      = "https://github.com/makersquare/active_record_tasks"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 4.0"
  spec.add_dependency "rake"
  spec.add_dependency "rainbow"

  spec.add_development_dependency "bundler", "~> 1.3"
end

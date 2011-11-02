# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jenkins/plugin/version"

Gem::Specification.new do |s|
  s.name        = "jenkins-plugin"
  s.version     = Jenkins::Plugin::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Charles Lowell"]
  s.email       = ["cowboyd@thefrontside.net"]
  s.homepage    = "http://github.com/cowboyd/jenkins-plugin"
  s.summary     = %q{Tools for creating and building Jenkins Ruby plugins}
  s.description = %q{I'll think of a better description later, but if you're reading this, then I haven't}

  s.rubyforge_project = "jenkins-plugin"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rubyzip"
  s.add_dependency "thor"
  s.add_dependency "jenkins-war", ">= 1.427"
  s.add_dependency "bundler", "~> 1.1.rc"
  s.add_dependency "jenkins-plugin-runtime", "~> 0.1.6"

  s.add_development_dependency "rspec", "~> 2.0"
  s.add_development_dependency "cucumber", "~> 1.0"
end

# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'monster/remote/version'

Gem::Specification.new do |s|
  s.name        = "monster"
  s.version     = Monster::Remote::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ricardo Valeriano"]
  s.email       = ["ricardovaleriano.com"]
  s.homepage    = "http://github.com/ricardovaleriano/monster_remote"
  s.summary     = "Publish your jekyll blog via ftp easy as pie"
  s.description = "This gem allow you publish your jekyll static site via FTP, easy as pie."

  s.required_rubygems_version = ">= 1.8.10"

  s.add_development_dependency "rspec"
  s.add_development_dependency "fakefs"

  s.files        = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  #s.executables  = ['monster']
  s.require_path = 'lib'
end

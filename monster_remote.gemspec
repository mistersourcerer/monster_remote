# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "monster_remote"
  s.version     = "0.1.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ricardo Valeriano"]
  s.email       = ["ricardo.valeriano@gmail.com"]
  s.homepage    = "http://github.com/ricardovaleriano/monster_remote"
  s.summary     = "Publish your jekyll blog via ftp easy as pie"
  s.description = "This gem allow you publish your jekyll static site via FTP, easy as pie."

  s.required_rubygems_version = ">= 0"

  s.add_development_dependency "rspec"
  s.add_development_dependency "fakefs"

	s.require_path = 'lib'
	
  s.files         = ["Gemfile", "LICENSE", "README.md", "Rakefile", "bin/monster_remote", "lib/monster/remote.rb", "lib/monster/remote/cli.rb", "lib/monster/remote/configuration.rb", "lib/monster/remote/filters/filter.rb", "lib/monster/remote/filters/name_based_filter.rb", "lib/monster/remote/sync.rb", "lib/monster/remote/wrappers/net_ftp.rb", "lib/monster_remote.rb", "monster_remote.gemspec", "spec/monster/remote/cli_spec.rb", "spec/monster/remote/configuration_spec.rb", "spec/monster/remote/filters/filter_spec.rb", "spec/monster/remote/filters/name_based_filter_spec.rb", "spec/monster/remote/sync_spec.rb", "spec/monster/remote/wrappers/net_ftp_spec.rb", "spec/spec_helper.rb"]
  s.test_files    = ["spec/monster/remote/cli_spec.rb", "spec/monster/remote/configuration_spec.rb", "spec/monster/remote/filters/filter_spec.rb", "spec/monster/remote/filters/name_based_filter_spec.rb", "spec/monster/remote/sync_spec.rb", "spec/monster/remote/wrappers/net_ftp_spec.rb", "spec/spec_helper.rb"]

	
  s.executables  = ["monster_remote"]
	
end

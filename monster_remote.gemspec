# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "monster_remote"
  s.version     = "0.0.1"
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
	
  s.files         = ["Gemfile", "LICENSE", "README.md", "Rakefile", "lib/monster/remote.rb", "lib/monster/remote/content_name_based_filter.rb", "lib/monster/remote/sync.rb", "lib/monster/remote/tasks/gemspec.erb", "lib/monster/remote/tasks/gemspec_generator.rb", "lib/monster/remote/version.rb", "lib/monster/remote/wrappers/net_ftp.rb", "monster_remote.gemspec", "spec/monster/remote/content_name_based_filter_spec.rb", "spec/monster/remote/sync_spec.rb", "spec/monster/remote/wrappers/net_ftp_spec.rb", "spec/spec_helper.rb"]
  s.test_files    = ["spec/monster/remote/content_name_based_filter_spec.rb", "spec/monster/remote/sync_spec.rb", "spec/monster/remote/wrappers/net_ftp_spec.rb", "spec/spec_helper.rb"]
end

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rspec/core/rake_task'
require 'monster/remote/tasks/gemspec_generator'

task :default => [:specs]
task :specs => [:"specs:all"]
namespace :specs do
  RSpec::Core::RakeTask.new "all" do |t|
    t.pattern = "spec/**/*_spec.rb"
    t.rspec_opts = ['--color', '--format documentation', '--require spec_helper']
  end
end

namespace :gemspec do
  desc "generate the gemspec file"
  task :create do
    Monster::Remote::GemspecGenerator.new.generate
  end
end

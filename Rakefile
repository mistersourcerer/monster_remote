task :default => [:specs]
task :specs => [:"specs:all"]
namespace :specs do
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new "all" do |t|
    t.pattern = "spec/**/*_spec.rb"
    t.rspec_opts = ['--color', '--format documentation', '--require spec_helper']
  end
end

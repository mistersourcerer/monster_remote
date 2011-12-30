require 'erb'
require "monster/remote/version"

module Monster
  module Remote

    class GemspecGenerator

      def generate(erb="gemspec.erb", gemspec_file="#{Monster::Remote::NAME}.gemspec")
        template_path = File.join(File.expand_path("./lib/monster/remote/tasks"), erb)
        template = ERB.new(IO.read(template_path))
        File.open(gemspec_file, "w") do |file|
          scope_vars = gemspec_scope(files, test_files)
          file.write(template.result(scope_vars))
        end
      end

      private
      def git_files(param=nil)
        all_files = `git ls-files #{param}`.split("\n")
      end

      def files
        git_files.reject do |file|
        	file =~ /\.(gitignore|rvmrc)|Gemfile.lock/
        end
      end

      def test_files
        git_files("-- spec/*")
      end

      def executable_files
        git_files("-- bin/*")
      end

      def gemspec_scope(files, test_files)
        Object.new.instance_eval {
          name    = Monster::Remote::NAME
          version = Monster::Remote::VERSION
          files   = files || []

          test_files        = test_files || []
          executable_files  = executable_files || []

          binding
        }
      end

    end

  end
end

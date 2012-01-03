require 'optparse'

module Monster
  module Remote

    class CLI

      def run(args=ARGV)
        options = parse_options(args)
        show_version if options[:show_version]
      end

      def show_version
        puts Monster::Remote::VERSION
        exit(0)
      end

      private
      def parse_options(args, options={})
        parser = OptionParser.new do |opts|
          opts.banner = "monster_remote v#{Monster::Remote::VERSION}"
          opts.banner << " :: Remote sync your jekyll site :: Usage: monster_remote [options]"

          opts.on "-v", "--version", "Show installed gem version" do
            options[:show_version] = true
          end
        end

        parser.parse!(args)
        options
      end

    end # CLI
  end
end

require 'optparse'

module Monster
  module Remote

    class CLI

      def initialize(syncer=Sync, out=STDOUT, input=STDIN)
        @syncer = syncer
        @out = out
        @in = input
      end

      def run(args=ARGV)
        options = parse_options(args)

        show_version if options[:show_version]
        wait_for_password if options[:password]

        connection_wrapper = options[:wrapper] || Monster::Remote::Wrappers::NetFTP
        local_dir = options[:local_dir] || Dir.pwd
        remote_dir = options[:remote_dir] || File.basename(local_dir)
        out = options[:verbose] ? STDOUT : nil
        sync = @syncer.new(connection_wrapper, local_dir, remote_dir, out)
      end

      def show_version
        @out.puts Monster::Remote::VERSION
        exit(0)
      end

      def wait_for_password
        @password = @in.gets.strip
      end

      private
      def parse_options(args, options={})
        parser = OptionParser.new do |opts|
          opts.banner = "monster_remote v#{Monster::Remote::VERSION}"
          opts.banner << " :: Remote sync your jekyll site :: Usage: monster_remote [options]"

          opts.on "-v", "--version", "Show version" do
            options[:show_version] = true
          end

          opts.on "-p", "--password", "Password for connection" do
            options[:password] = true
          end

          opts.on "--ftp", "Transfer with NetFTP wrapper" do
            options[:wrapper] = Monster::Remote::Wrappers::NetFTP
          end

          opts.on "--verbose", "Verbose mode" do
            options[:verbose] = true
          end

          opts.on "-l", "--local-dir DIR_PATH", "Local dir to replicate" do |dir|
            options[:local_dir] = dir
          end

          opts.on "-r", "--remote-dir DIR_PATH", "Remote root dir" do |dir|
            options[:remote_dir] = dir
          end
        end

        parser.parse!(args)
        options
      end

    end # CLI
  end
end

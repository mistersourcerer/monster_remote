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
        password = nil
        if options[:password]
          password = wait_for_password
        end

        connection_wrapper = options[:wrapper] || Monster::Remote::Wrappers::NetFTP
        local_dir = options[:local_dir] || Dir.pwd
        remote_dir = options[:remote_dir] || File.basename(local_dir)
        out = options[:verbose] ? STDOUT : nil
        host = options[:host] || "localhost"
        port = options[:port] || 21
        user = options[:user] || nil

        sync = @syncer.new(connection_wrapper, local_dir, remote_dir, out)
        sync.start(user, password, host, port)
      end

      def show_version
        @out.puts Monster::Remote::VERSION
        exit(0)
      end

      def wait_for_password
        @out.print "password:"

        system("stty -echo")

        password = @in.gets.strip

        system("stty echo")
        system("echo \"\"")

        password
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

          opts.on "-u", "--user USER", "User for connection" do |user|
            options[:user] = user
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

          opts.on "-H", "--host HOST", "Server host" do |host|
            options[:host] = host
          end

          opts.on "-P", "--port SERVER_PORT", "Server port" do |port|
            options[:port] = port
          end
        end

        parser.parse!(args)
        options
      end

    end # CLI
  end
end

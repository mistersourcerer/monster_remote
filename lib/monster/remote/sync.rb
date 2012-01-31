module Monster
  module Remote

    class Sync

      attr_writer :verbose, :local_dir, :remote_dir

      def initialize(wrapper)
        @wrapper = wrapper
      end

      def start
        wrapper = @wrapper || raise(MissingProtocolWrapperError)
        local_dir || raise(MissingLocalDirError)
        remote_dir || raise(MissingRemoteDirError)

        out("syncing from: #{local_dir} to: #{remote_dir}")

        open(wrapper) do |wrapper|
          out("connection openned, using: #{wrapper}")
          Dir.entries(local_dir).each do |entry|
            copy_to_remote(wrapper, entry)
          end
        end
      end

      private
      def copy_to_remote(wrapper, entry)
        item = File.join(local_dir, entry)
        remote_item = File.join(remote_dir, entry)
        if File.directory?(item)
          out("creating remote dir #{remote_item}")
          wrapper.create_dir(remote_item)
          Dir.entries(item).each do |dir|
            puts ":::::::::"
            puts File.join(item, dir)
            copy_to_remote(wrapper, File.join(item, dir))
          end
        end
      end

      def out(msg)
        @verbose && @verbose.puts(msg)
      end

      def local_dir
        @local_dir
      end

      def remote_dir
        @remote_dir
      end

      def open(wrapper, &block)
        begin
          wrapper.open &block
        rescue Exception => e
          raise NoConnectionError, e
        end
      end

    end# Sync

    class SyncOld

      def self.with
        Sync.new
      end

      def start
        @provider.open(@host, @port || 21, @user, @pass) do |con|
          con.copy_dir(@local_dir || "./_site", @remote_dir || ".")
        end
      end

      def add_filter(filter)
        @provider.add_filter(filter)
      end

      def local_dir(local_dir)
        @local_dir = local_dir
        self
      end

      def remote_dir(remote_dir)
        @remote_dir = remote_dir
        self
      end

      def remote_connection_provider(provider)
        @provider = provider
        self
      end

      def host(host)
        @host = host
        self
      end

      def port(port)
        @port = port
        self
      end

      def user(user)
        @user = user
        self
      end

      def pass(pass)
        @pass = pass
        self
      end
    end # Sync

  end
end

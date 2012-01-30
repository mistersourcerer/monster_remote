module Monster
  module Remote

    class Sync

      def initialize(wrapper)
        @wrapper = wrapper
      end

      def start
        wrapper = @wrapper || raise(MissingProtocolWrapperError)
        open(wrapper) do |wrapper|
          wrapper.copy_dir(local_dir, remote_dir)
        end
      end# start

      private
      def open(wrapper, &block)
        begin
          wrapper.open &block
        rescue Exception => e
          raise NoConnectionError.new(e)
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

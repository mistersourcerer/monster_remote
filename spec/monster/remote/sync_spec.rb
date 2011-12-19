module Monster
  module Remote

    describe Sync do

      def static_site_dir; "/omg/what/a/nice/dir"; end
      def remote_site_dir; "/my/remote/dir"; end
      def host; "localhost"; end
      def port; 211231; end
      def user; "mr. cueca"; end
      def pass; "big secret of mine"; end

      let(:connection) do
        double("internal connection mock").as_null_object
      end

      let(:provider) do
        class RemoteProtocolProviderMock
          class << self; attr_accessor :connection; end
          def open(*args); yield(RemoteProtocolProviderMock.connection); end
          def add_filter(filter); end
        end
        RemoteProtocolProviderMock.connection = connection
        RemoteProtocolProviderMock.new
      end

      before do
        @sync = Sync.with.
          local_dir(static_site_dir).
          remote_dir(remote_site_dir).
          remote_connection_provider(provider).
          host(host).
          port(port).
          user(user).
          pass(pass)

        filter = ContentNameBasedFilter.new
        filter.reject([".", ".."])
        @sync.add_filter(filter)
      end

      context "sending static site" do

        it "open a connection" do
          provider.should_receive(:open).with(host, port, user, pass).once
          @sync.start
        end

        it "use a connection to send the local dir" do
          connection.should_receive(:copy_dir).with(static_site_dir, remote_site_dir).once
          @sync.start
        end

      end # sending static site

      context "building static site" do

      end

    end #describe Sync
  end
end

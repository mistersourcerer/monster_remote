module Monster
  module Remote

    describe Sync do

      def static_site_dir
        "/omg/what/a/nice/dir"
      end

      def remote_site_dir
        "/my/remote/dir"
      end

      def mount_local_file_system
        
      end

      def local_dir_structure
        ["local"]
      end

      def mount_remote_file_system
        
      end

      def remote_dir_structure
        ["remote"]
      end

      def provider
        
      end

      def host; "localhost"; end
      def port; 211231; end
      def user; "mr. cueca"; end
      def pass; "big secret of mine"; end

      def provider
        provider = double("provider interface mock").as_null_object
        provider.stub(:open) do
          yield(double("internal connection mock").as_null_object)
        end
        provider
      end

      before(:all) do
        mount_local_file_system
      end

      before do
        mount_remote_file_system

        @sync = Sync.with.
          local_dir(static_site_dir).
          remote_dir(remote_site_dir).
          remote_connection_provider(provider).
          host(host).
          port(port).
          user(user).
          pass(pass)
      end

      it "open a connection" do
        provider.should_receive(:open).once
        @sync.start
      end

      it "create the remote dir, if it doesn't exists" do
        remote_dir_structure.include?(remote_site_dir).should be_false
        @sync.start
        remote_dir_structure.include?(remote_site_dir).should be_true
      end

      it "copy some local dir, to the remote dir" do
        @sync.start
        remote_dir_structure.should == local_dir_structure
      end

    end #describe Sync
  end
end

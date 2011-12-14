module Monster
  module Remote

    describe Sync do

      before(:all) do
        @sync = Sync.with.
          local_dir(static_site_dir).
          remote_dir(remote_site_dir).
          remote_connection_provider(provider).
          host(host).
          port(port).
          user(user).
          pass(pass)
      end

      before(:each) do
        clean_remote_file_system
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

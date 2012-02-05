require 'monster/remote/wrappers/net_ftp'

module Monster
  module Remote

    describe Sync do

      let(:verbose) { double("some object with #puts").as_null_object }

      def wrapper
        double("wrapper contract").as_null_object
      end

      def sync(wrapper)
        Sync.new(wrapper, local_dir, remote_dir)
      end

      before do
        FileUtils.mkdir_p(local_dir)
        create_dir_structure
        @wrapper = wrapper
        @sync = sync(@wrapper)
      end

      context "#start" do

        it "raise error if the local dir config is missing" do
          missing_local_dir = Monster::Remote::MissingLocalDirError
          sync = Sync.new(wrapper)
          lambda { sync.start }.should raise_error(missing_local_dir)
        end

        it "raise error if the remote dir config is missing" do
          missing_remote_dir = Monster::Remote::MissingRemoteDirError
          sync = Sync.new(wrapper, local_dir)
          lambda { sync.start }.should raise_error(missing_remote_dir)
        end

        it "raise error if asked to start without protocol wrapper" do
          missing_wrapper = Monster::Remote::MissingProtocolWrapperError
          lambda { Sync.new(nil).start }.should raise_error(missing_wrapper)
        end

        it "call wrapper's #open when #start" do
          @wrapper.should_receive(:open)
          @sync.start
        end

        it "raise NoConnectionError when can't #open connection" do
          @wrapper.should_receive(:open).and_raise(StandardError)
          no_connection = Monster::Remote::NoConnectionError
          lambda{ @sync.start }.should raise_error(no_connection)
        end

        context "calling wrapper's #open" do

          before do
            @wrapper.stub(:open) { |&bloco| bloco && bloco.call(@wrapper) }
          end
        end# #open
      end# #start

      describe "turns verbose if a object which responds_to? :puts is passed" do

        before do
          @sync.verbose = verbose
        end

        it "calls #puts on the output object" do
          verbose.should_receive(:puts).with("syncing from: #{local_dir} to: #{remote_dir}")
          @sync.start
        end

      end # verbose

      describe "with NetFTP wrapper" do

        before { @ftp_dir = File.join(ftp_root, remote_dir) }

        before(:each) do
          sync = Sync.new(Wrappers::NetFTP.new, local_dir, remote_dir)
          sync.start(ftp_user, ftp_password)
        end

        it "replicate a local dir structure to remote" do
          dir_structure.each do |dir, content|
            File.directory?(File.join(@ftp_dir, dir)).should be_true
          end
        end

        it "create copies all local files on the dir structure" do
          dir_structure.each do |dir, content|
            content.each do |f|
              file = File.join(File.join(@ftp_dir, dir), f)
              File.exists?(file).should be_true
            end
          end
        end
      end

      after do
        FileUtils.rm_rf(spec_tmp)
      end

    end# Sync
  end
end

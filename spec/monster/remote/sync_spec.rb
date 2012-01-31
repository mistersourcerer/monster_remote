module Monster
  module Remote

    describe Sync do


      let(:dir_structure) {
        {
          "site" => ["xpto.txt"],
          "site/images" => ["img1", "img2", "img3"],
          "site/borba" => ["file1", "file2"],
          "site/borba/subdir" => ["entaro", "adum", "toredas"],
          "site/borba/subdir/test" => ["go1", "go2", "go3"]
        }
      }

      let(:local_dir) { File.join(spec_tmp, "_ftp_") }

      let(:remote_dir) { File.join("tmp", "_ftp_") }

      let(:verbose) { double("some object with #puts").as_null_object }

      def create_dir_structure
        dir_structure.each do |dir, files|
          dir = File.join(local_dir, dir)
          FileUtils.mkdir_p(dir)
          files.each do |file|
            File.open(File.join(dir, file), "w") do |f|
              f.write(file)
            end
          end
        end
      end

      def wrapper
        double("wrapper contract").as_null_object
      end

      def sync(wrapper)
        s = Sync.new(wrapper)
        s.local_dir = local_dir
        s.remote_dir = remote_dir
        s
      end

      before do
        FileUtils.mkdir_p(local_dir)
        create_dir_structure
      end

      context "#start" do

        before(:each) do
          @wrapper = wrapper
          @sync = sync(@wrapper)
        end

        it "raise error if the local dir config is missing" do
          missing_local_dir = Monster::Remote::MissingLocalDirError
          @sync.local_dir = nil
          lambda { @sync.start }.should raise_error(missing_local_dir)
        end

        it "raise error if the remote dir config is missing" do
          missing_remote_dir = Monster::Remote::MissingRemoteDirError
          @sync.remote_dir = nil
          lambda { @sync.start }.should raise_error(missing_remote_dir)
        end

        it "raise error if asked to start without protocol wrapper" do
          missing_wrapper = Monster::Remote::MissingProtocolWrapperError
          lambda { Sync.new(nil).start }.should raise_error(missing_wrapper)
        end

        it "call wrapper's #open" do
          @wrapper.should_receive(:open)
          @sync.start
        end

        it "call wrapper's #open" do
          @wrapper.should_receive(:open).and_raise(StandardError)
          no_connection = Monster::Remote::NoConnectionError
          lambda{ @sync.start }.should raise_error(no_connection)
        end

        context "calling wrapper's #open" do

          before(:each) do
            @wrapper = wrapper
            @sync = sync(@wrapper)
            @wrapper.stub(:open) { |bloco| bloco && bloco.call(@wrapper) }
          end

          it "call #create_dir to the root remote path" do
            @wrapper.should_receive(:create_dir).with(remote_dir).once
            @sync.start
          end# once per dir

          it "call #create_dir once per local dir" do
            @wrapper.should_receive(:create_dir).exactly(dir_structure.size+1)
            @sync.start
          end# once per dir

          it "call #copy_file once per file in dir" do
            total_files = dir_structure.inject(0) { |sum, pair| sum + pair[1].size }
            @wrapper.should_receive(:copy_file).exactly(total_files)
            @sync.start
          end
        end# #open
      end# #start

      describe "turns verbose if a object which responds_to? :puts is passed" do

        before(:each) do
          @wrapper = wrapper
          @sync = sync(@wrapper)
          @sync.verbose = verbose
        end

        it "calls #puts on the output object" do
          verbose.should_receive(:puts).with("syncing from: #{local_dir} to: #{remote_dir}")
          @sync.start
        end

      end # verbose

      after do
        FileUtils.rm_rf(spec_tmp)
      end

    end# Sync
  end
end

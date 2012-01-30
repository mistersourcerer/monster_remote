module Monster
  module Remote

    describe Sync do

      let(:dir_structure) do
        {
          "site" => ["xpto.txt"],
          "site/images" => ["img1", "img2", "img3"],
          "site/borba" => ["file1", "file2"],
          "site/borba/subdir" => ["entaro", "adum", "toredas"],
          "site/borba/subdir/test" => ["go1", "go2", "go3"]
        }
      end
      let(:local_dir) { File.join(spec_tmp, "_ftp_") }
      let(:remote_dir) { File.join("tmp", "_ftp_") }
      let(:wrapper) { double("wrapper").as_null_object }
      let(:sync) { Sync.new(wrapper) }

      context "#start" do

        it "raise error if asked to start without protocol wrapper" do
          missing_wrapper = Monster::Remote::MissingProtocolWrapperError
          lambda { Sync.new(nil).start }.should raise_error(missing_wrapper)
        end

        it "call wrapper's #open" do
          wrapper.should_receive(:open)
          sync.start
        end

        it "call wrapper's #open" do
          wrapper.should_receive(:open).and_raise(StandardError)
          no_connection = Monster::Remote::NoConnectionError
          lambda{ sync.start }.should raise_error(no_connection)
        end

        context "calling wrapper's #open" do
          before do
            wrapper.stub(:open) { |bloco| bloco && bloco.call(wrapper) }
          end

          it "call #copy_dir once per local dir" do
            wrapper.should_receive(:create_dir).exactly(dir_structure.size)
            sync.start
          end# once per dir

          it "call #copy_dir once per local dir" do
            to = File.join(remote_dir, dir_structure.keys.first)
            wrapper.should_receive(:create_dir).with(to).once
            sync.start
          end# once per dir
        end# #open
      end# #start
    end# Sync
  end
end

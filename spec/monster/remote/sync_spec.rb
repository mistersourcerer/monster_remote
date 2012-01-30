module Monster
  module Remote

    describe Sync do

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

        it "call wrapper's #open" do
          wrapper.should_receive(:copy_dir).with(local_dir_path)
          # add times here, should receive copy_dir for each dir in the
          # stucture
          sync.start
        end
      end# #start
    end# Sync
  end
end

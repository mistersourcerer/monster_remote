module Monster
  module Remote
    module Wrappers

      describe NetFTP, "copy some local directory, to the remote host" do

        let(:host) { "host" }
        let(:user) { "user" }
        let(:password) { "pass" }
        let(:port) { "port" }

        let(:con) { double("Net::FTP::con mock").as_null_object }

        let(:driver) {
          d = double("Net::FTP mock").as_null_object
          d.stub(:new).and_return(con)
          d
        }

        let(:wrapper) { NetFTP.new(driver) }

        before do
          FileUtils.mkdir_p(local_dir)
          create_dir_structure
        end

        it "create a Net::FTP object" do
          driver.should_receive(:new).once
          wrapper.open(host, user, password, port)
        end

        it "connect to the right host and port" do
          con.should_receive(:connect).with(host, port).once
          wrapper.open(host, user, password, port)
        end

        it "authenticate on server" do
          con.should_receive(:login).with(user, password).once
          wrapper.open(host, user, password, port)
        end

        it "close connection" do
          con.should_receive(:close).once
          wrapper.open(host, user, password, port)
        end

        context "#open" do

          it "yields a given block" do
            opalhes = 0
            wrapper.open(host, user, password, port) { opalhes = 1 }
            opalhes.should == 1
          end

          it "yields a given block passing the wrapper as argument" do
            internal_wrapper = nil
            wrapper.open(host, user, password, port) {|wrapper| internal_wrapper = wrapper }
            internal_wrapper.should be_equal(wrapper)
          end

          it "yields a given block passing the con as second argument" do
            internal_con = nil
            wrapper.open(host, user, password, port) {|first, con| internal_con = con }
            internal_con.should be_equal(con)
          end
        end

        after do
          FileUtils.rm_rf(spec_tmp)
        end

      end# NetFTP
    end# Wrappers
  end# Remote
end# Monster

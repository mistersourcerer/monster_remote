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

        describe "#open" do

          context "yields a given block" do

            it "yields a block" do
              opalhes = 0
              wrapper.open(host, user, password, port) { opalhes = 1 }
              opalhes.should == 1
            end

            it "the first block arg responds_to? :create_dir" do
              handler = nil
              wrapper.open(host, user, password, port) {|h| handler = h }
              handler.should respond_to(:create_dir)
            end

            it "the first block arg responds_to? :copy_file" do
              handler = nil
              wrapper.open(host, user, password, port) {|h| handler = h }
              handler.should respond_to(:copy_file)
            end

            it "yields a given block passing the con as second argument" do
              internal_con = nil
              wrapper.open(host, user, password, port) {|first, con| internal_con = con }
              internal_con.should be_equal(con)
            end

          end# yielding the block

          context "uses a ftp connection" do

            def ftp_cleanup
              ftp = Net::FTP.new
              ftp.connect("localhost")
              ftp.login("tests", "t3st3")
              list = ftp.list

              dir_exists = list.select{ |item| item =~ /.* opalele$/ }.size > 0
              if dir_exists
                ftp.rmdir("opalele")
              end

              file_exists = list.select{ |item| item =~ /.* zufa$/ }.size > 0
              if file_exists
                ftp.delete("zufa")
              end

              ftp.close
            end

            before(:each) do
              ftp_cleanup
            end

            let(:ftp_root) { "/Users/test" }

            it "creates a remote dir" do
              ftp = NetFTP.new
              ftp.open("localhost", "tests", "t3st3", 21) do |remote|
                remote.create_dir("opalele")
              end
              File.directory?(File.join(ftp_root, "opalele")).should be_true
            end

            context "copying file" do

              before do
                file = File.join(local_dir, "omg_filet.txt")
                @content = "ula ula ula baboola"
                File.open(file, "w") { |f| f.write @content }

                ftp = NetFTP.new
                ftp.open("localhost", "tests", "t3st3", 21) do |remote|
                  remote.copy_file(file, "zufa")
                end
              end

              it "copies the file" do
                File.exists?(File.join(ftp_root, "zufa")).should be_true
              end

              it "copy with right content" do
                IO.read(File.join(ftp_root, "zufa")).should == @content
              end

            end# copying file

            after do
              ftp_cleanup
            end

          end# ftp connection
        end# #open

        after do
          FileUtils.rm_rf(spec_tmp)
        end

      end# NetFTP
    end# Wrappers
  end# Remote
end# Monster

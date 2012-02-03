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

            let(:ftp_root) { "/Users/test" }

            before(:each) do
              ftp_cleanup
            end

            context "handling directories" do

              it "creates a remote dir" do
                ftp = NetFTP.new
                ftp.open("localhost", "tests", "t3st3", 21) do |remote|
                  puts "pimba"
                  remote.create_dir("opalele")
                end
                File.directory?(File.join(ftp_root, "opalele")).should be_true
              end

              it "creates a dir recursivelly" do
                ftp = NetFTP.new
                ftp.open("localhost", "tests", "t3st3", 21) do |remote|
                  remote.create_dir("zaz/zumzum/goal/")
                end
                File.directory?(File.join(ftp_root, "zaz/zumzum/goal")).should be_true
              end

              it "removes a dir" do
                ftp = NetFTP.new
                ftp.open("localhost", "tests", "t3st3", 21) do |remote|
                  remote.create_dir("opalele")
                  remote.remove_dir("opalele")
                end
                File.directory?(File.join(ftp_root, "opalele")).should be_false
              end

              it "removes a dir recursively (a non empty dir)" do
                ftp = NetFTP.new
                ftp.open("localhost", "tests", "t3st3", 21) do |remote|
                  remote.create_dir("zaz/zumzum/goal")
                  remote.remove_dir("zaz/zumzum/goal")
                end
                File.directory?(File.join(ftp_root, "zaz/zumzum/goal")).should be_false
              end

              it "overrides an existent dir" do
                ftp = NetFTP.new
                ftp.open("localhost", "tests", "t3st3", 21) do |remote|
                  lambda {
                    remote.create_dir("opalele")
                    remote.create_dir("opalele")
                  }.should_not raise_error
                end
              end

            after do
              ftp_cleanup
            end

            end

            context "copying file" do
              def file_content
                "ula ula ula baboola"
              end

              def create_tmp_file
                file = File.join(local_dir, "omg_filet.txt")
                File.open(file, "w") { |f| f.write file_content }
                file
              end

              before do
                ftp = NetFTP.new
                ftp.open("localhost", "tests", "t3st3", 21) do |remote|
                  remote.copy_file(create_tmp_file, "zufa")
                end
              end

              it "copies the file" do
                File.exists?(File.join(ftp_root, "zufa")).should be_true
              end

              it "copy with right content" do
                IO.read(File.join(ftp_root, "zufa")).should == file_content
              end

              it "removes a file" do
                ftp = NetFTP.new
                ftp.open("localhost", "tests", "t3st3", 21) do |remote|
                  remote.copy_file(create_tmp_file, "zufa")
                  remote.remove_file("zufa")
                end
                File.exists?(File.join(ftp_root, "zufa")).should be_false
              end

              it "overrides existent file" do
                ftp = NetFTP.new
                ftp.open("localhost", "tests", "t3st3", 21) do |remote|
                  lambda {
                    remote.copy_file(create_tmp_file, "zufa")
                    remote.copy_file(create_tmp_file, "zufa")
                  }.should_not raise_error
                end
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

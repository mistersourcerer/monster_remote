module Monster
  module Remote
    module Wrappers

      describe NetFTP, "copy some local directory, to the remote host" do

        def dir_structure
          @dir_structure ||= ["my", "my/dir", "my/other/dir"]
        end

        def root_local_dir
          File.expand_path("spec/tmp/opalhes")
        end

        def root_remote_dir
          "/Users/test/tmp"
        end

        def local_dirs
          @local_dirs ||= dir_structure.map {|dir| File.join(root_local_dir, dir)}
        end

        def local_files
          @local_files ||= @local_dirs.map { |dir| File.join(dir, "file.txt") }
        end

        def create_local_dir_structure
          local_dirs.each {|dir| FileUtils.mkdir_p(dir)}
          local_files.each {|file| File.open(file, "w") {|f| f.write "opalhes"} }
        end

        def clean_local_dir
          FileUtils.rm_rf File.expand_path("spec/tmp")
        end

        def clean_remote_dir
          FileUtils.rm_rf root_remote_dir
        end

        let(:connection) do
          connection = double("Ftp Connection Mock").as_null_object
          connection.stub!(:ls).and_return([]);
          connection
        end

        let(:net_ftp_mock) do
          class NetFtpMock

            class << self

              attr_accessor :connection

              def open(*args)
                yield(self.connection)
              end
            end

            def connect(*args); end
            def login(*args); end
          end

          NetFtpMock.connection = connection
          NetFtpMock
        end

        let(:ftp) do
          NetFTP.new(net_ftp_mock)
        end

        before(:all) do
          @host, @port, @user, @pass = "localhost", 124523, "I CAN HAZ USER", "mi mi mi my secret"
          create_local_dir_structure
        end

        context "#open, operations within the a block" do

          it "yields the block" do
            outer_block_var = nil
            ftp.open(@host, @port, @user, @pass) do
              outer_block_var = "holla que tal"
            end
            outer_block_var.should_not be_nil
          end

          it "pass an object which knows how to #copy_dir" do
            object = nil
            ftp.open(@host, @port, @user, @pass) do |instance|
              object = instance
            end
            object.should respond_to(:copy_dir)
          end

          it "create the ftp connection" do
            connection.should_receive(:connect).with(@host, @port)
            ftp.open(@host, @port, @user, @pass) {}
          end

          it "login into the ftp server" do
            connection.should_receive(:login).with(@user, @pass)
            ftp.open(@host, @port, @user, @pass) {}
          end

          it "pass the ftp as second argumento to block" do
            ftp.open(@host, @port, @user, @pass) do |block_instance, con|
              con.should be_equal(connection)
            end
          end 

          after(:each) do
            connection.clear_actual_received_count!
          end
        end # context #open

        context "#copy_dir" do

          before do
            clean_remote_dir
          end

          it "check existence of root remote dir" do
            ftp.open(@host, @port, @user, @pass) do |con|
              con.copy_dir(root_local_dir, root_remote_dir)
            end
          end

          it "create root remote dir if it doesn't exists" do
            pending "until we discover a way to clean remote dir"
            connection.should_receive(:mkdir).with(root_remote_dir)
            ftp.open(@host, @port, @user, @pass) do |con|
              con.copy_dir(root_local_dir, root_remote_dir)
            end
          end
        end # context #copy_dir

        context "#copy_dir, integration" do

          def dir_entries(root_dir)
            entries = []
            entries << root_dir
            Dir.entries(root_dir).reject{|entry| entry == "." || entry == ".."}.each do |entry_name|
              dir = File.join(root_dir, entry_name)
              if File.directory?(dir)
                entries += dir_entries(dir)
              else
                entries << dir
              end
            end
            entries
          end

          before(:all) do
            @host, @port, @user, @pass = "localhost", 21, "test", "test"
          end

          it "raise NetFTPPermissionDenied when tries create dir without permission" do
            lambda{
              NetFTP.new.open(@host, @port, @user, @pass) do |ftp|
                ftp.copy_dir(root_local_dir, "/")
              end
            }.should raise_exception(NetFTPPermissionDenied)
          end

          it "replicate local dir on ftp server" do
            NetFTP.new.open(@host, @port, @user, @pass) do |ftp|
              ftp.copy_dir(root_local_dir, root_remote_dir)
            end
            local_structure = dir_entries(root_local_dir).map {|entry| entry.gsub(root_local_dir, "")}
            remote_structure = dir_entries(root_remote_dir).map {|entry| entry.gsub(root_remote_dir, "")}
            remote_structure.should == local_structure
          end
        end # #copy_dir integration

        after(:all) do
          clean_local_dir
        end
      end # describe NetFTP
    end
  end
end

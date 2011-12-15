module Monster
  module Remote
    module Wrappers

      describe NetFTP, "copy some local directory, to the remote host" do

        def dir_structure
          @dir_structure ||= ["my", "my/dir", "my/other/dir"]
        end

        def root_local_dir
          "spec/tmp"
        end

        def root_remote_dir
          "/Users/test/tmp"
        end

        let(:connection) do
          connection = double("Ftp Connection Mock").as_null_object
          #connection.stub(:nlst).and_return(remote_dir_list);
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
        end # context #open

        context "#copy_dir" do

          it "check existence of root remote dir" do
            connection.should_receive(:nlst).once
          end

          it "create root remote dir if it doesn't exists" do
            connection.should_receive(:mkdir).with(root_remote_dir).once
          end

          it "create dir structure" do
            dir_structure.each do |dir|
              connection.should_receive(:mkdir).with(File.join(root_remote_dir, dir))
            end
          end
        end # context #copy_dir

        context "#copy_dir, integration" do

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
            FileUtils.rm_rf root_local_dir
          end

          before(:all) do
            create_local_dir_structure
            @host, @port, @user, @pass = "localhost", 21, "test", "test"
          end

          before(:each) do
            ftp.copy_dir(root_local_dir, root_remote_dir)
          end

          it "replicate local dir on ftp server" do
            NetFTP.new.open(@host, @port, @user, @pass) do |ftp|
              ftp.copy_dir(root_local_dir, root_remote_dir)
            end
            Dir.entries(root_local_dir).should == Dir.entries(root_remote_dir)
          end

          after(:all) do
            clean_local_dir
          end
        end # #copy_dir integration

      end # describe NetFTP
    end
  end
end

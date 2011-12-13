module Monster
  module FTPWrapper

    describe NetFTPWrapper do
      before(:all) do
        @host, @port, @user, @pass = "localhost", 28273, "user", "pass"
      end

      def remote_dir_list
        @remote_dir_list ||= [
          ".CFUserTextEncoding",
          ".DS_Store",
          "Applications",
          "Backup"
        ]
        @remote_dir_list
      end

      let(:net_ftp_con) do
        double("Net::FTP con mock").as_null_object
      end

      let(:connection) do
        connection = double("Ftp Connection Mock").as_null_object
        connection.stub(:nlst).and_return(remote_dir_list);
        connection
      end

      let(:ftp) do
        class AbstractionMock
          class << self
            attr_accessor :connection
          end

          def self.open(*args)
            yield(self.connection)
          end

          def connect(*args)
          end

          def login(*args)
          end
        end

        AbstractionMock.connection = connection
        NetFTPWrapper.new(AbstractionMock)
      end

      describe "#open (operations within a block)" do

        it "yields the block" do
          ftp.open(@host, @port, @user, @pass) do |block_instance|
            block_instance.should be_equal(ftp)
          end
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

        describe "#copy_files" do

          context "within new remote dir" do

            it "create the new remote dir" do
              @new_file_path = "/test/file"

              connection.should_receive(:mkdir).with("/test")
            end

            it "create the new remote dir, recursively if needed" do
              @new_file_path = "/test/my/new/file"

              connection.should_receive(:mkdir).with("/test")
              connection.should_receive(:mkdir).with("/test/my")
              connection.should_receive(:mkdir).with("/test/my/new")
            end
          end
        end

      end
    end
  end
end

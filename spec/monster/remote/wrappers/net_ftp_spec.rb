module Monster
  module Remote
    module Wrappers

      describe NetFTP, "copy some local directory, to the remote host" do
        def remote_dir_list
          @remote_dir_list ||= [
            ".CFUserTextEncoding",
            ".DS_Store",
            "Applications",
            "Backup"
          ]
          @remote_dir_list
        end

        let(:connection) do
          connection = double("Ftp Connection Mock").as_null_object
          connection.stub(:nlst).and_return(remote_dir_list);
          connection
        end

        let(:net_ftp_mock) do
          class NetFtpMock
            class << self; attr_accessor :connection; end
            def self.open(*args); yield(self.connection); end
            def connect(*args); end
            def login(*args); end
          end

          NetFtpMock.connection = connection
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

      end # describe NetFTP
    end
  end
end

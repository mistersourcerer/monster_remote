module Monster
  describe FTP do

    before(:all) do
      @host, @port, @user, @pass = "localhost", "21", "user", "pass"
    end

    let(:server) do
      double("FTP Server").as_null_object
    end

    let(:connection) do
      double("Ftp Connection Mock").as_null_object
    end

    let(:ftpabs) do
      class AbstractionMock
        class << self
          attr_accessor :connection
        end

        def self.open(*args)
          yield(self.connection)
        end
      end

      AbstractionMock.connection = connection

      AbstractionMock
    end

    let(:ftp) do
      FTP.new(@host, @port, @user, @pass, ftpabs)
    end

    context "#send_directory" do

      it "connect on server" do
        ftpabs.should_receive(:open).with(@host) {}
        ftp.send_directory(".")
      end

      it "create ftp connection" do
        connection.should_receive(:connect).with(@host, @port)
        ftp.send_directory(".")
      end

    end

  end
end

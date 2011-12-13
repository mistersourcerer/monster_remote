module Monster
  describe FTP do

    before(:all) do
      @host, @port, @user, @pass = "localhost", "21", "user", "pass"
      @remote_dir_list ||= []
    end

    let(:server) do
      double("FTP Server").as_null_object
    end

    let(:connection) do
      connection = double("Ftp Connection Mock").as_null_object
      @remote_dir_list = [
        ".CFUserTextEncoding",
        ".DS_Store",
        "Applications",
        "Backup"
      ]
      connection.stub(:nlst).and_return(@remote_dir_list);
      connection
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

    def send_directory_within_dir_structure(dir="/teste", remote = "/teste", &block)
      FakeFS do
        FileUtils.mkdir_p("#{dir}/subdir")
        File.open("#{dir}/README", 'w') { |f| f.write 'N/A' }
        File.open("#{dir}/subdir/README", 'w') { |f| f.write 'N/A' }
        if block_given?
          block.call(dir, remote)
        end
        ftp.send_directory(dir)
      end
    end

    context "#send_directory" do

      describe "ftp connection" do

        it "connect on server" do
          ftpabs.should_receive(:open).with(@host) {}
          send_directory_within_dir_structure
        end

        it "create ftp connection" do
          connection.should_receive(:connect).with(@host, @port)
          send_directory_within_dir_structure
        end

        it "login into ftp connection" do
          connection.should_receive(:login).with(@user, @pass)
          send_directory_within_dir_structure
        end

      end

      describe "sending directory content" do

        context "remote dir doesn't exists" do

          it "verify remote dir existence" do
            connection.should_receive(:nlst)
            send_directory_within_dir_structure
          end

          it "create remote dir" do
            send_directory_within_dir_structure do |dir|
              connection.should_receive(:mkdir).with(dir)
            end
          end
        end

        context "remote dir already exists" do

          it "create remote dir" do
            @original_remote_dir_list = connection.nlst
            send_directory_within_dir_structure do |dir, remote|
              connection.stub(:nlst).and_return([
                ".CFUserTextEncoding",
                ".DS_Store",
                "Applications",
                "Backup",
                remote
              ]);

              connection.should_not_receive(:mkdir).with(remote)
            end

            connection.stub(:nlst).and_return(@original_remote_dir_list)
          end
        end

        it "list all remote dirs just once" do
          send_directory_within_dir_structure do
            connection.should_receive(:nlst).once
          end
        end

        it "copy an entire dir structure" do
          send_directory_within_dir_structure do |dir, remote|
            connection.should_receive(:putbinaryfile).with("#{dir}/README", "#{remote}/README").and_return(true)
            connection.should_receive(:mkdir).with("#{dir}/subdir")
            connection.should_receive(:putbinaryfile).with("#{dir}/subdir/README", "#{remote}/subdir/README").and_return(true)
          end
        end

      end
    end
  end
end

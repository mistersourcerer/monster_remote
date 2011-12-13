module Monster
  describe FTP do

    before(:all) do
      @host, @port, @user, @pass = "localhost", "21", "user", "pass"
    end

    let(:server) do
      double("FTP Server").as_null_object
    end

    let(:connection) do
      connection = double("Ftp Connection Mock").as_null_object
      connection.stub(:nlst).and_return([
        ".CFUserTextEncoding",
        ".DS_Store",
        "Applications",
        "Backup"
      ]);
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

    def within_dir_structure(dir="/teste", remote = "/teste", &block)
      FakeFS do
        FileUtils.mkdir_p("#{dir}/subdir")
        File.open("#{dir}/README", 'w') { |f| f.write 'N/A' }
        File.open("#{dir}/subdir/README", 'w') { |f| f.write 'N/A' }
        block.call(dir, remote)
      end
    end

    context "#send_directory" do

      describe "ftp connection" do

        it "connect on server" do
          ftpabs.should_receive(:open).with(@host) {}
          within_dir_structure do |dir, remote|
            ftp.send_directory(dir)
          end
        end

        it "create ftp connection" do
          connection.should_receive(:connect).with(@host, @port)
          within_dir_structure do |dir, remote|
            ftp.send_directory(dir)
          end
        end

        it "login into ftp connection" do
          connection.should_receive(:login).with(@user, @pass)
          within_dir_structure do |dir, remote|
            ftp.send_directory(dir)
          end
        end

      end

      describe "sending directory content" do

        context "remote dir doesn't exists" do

          it "verify remote dir existence" do
            connection.should_receive(:nlst)
            within_dir_structure do |dir, remote|
              ftp.send_directory(dir)
            end
          end

          it "create remote dir" do
            within_dir_structure do |dir, remote|
              connection.should_receive(:mkdir).with(dir)
              ftp.send_directory(dir)
            end
          end

        end

        it "copy an entire dir structure" do
          within_dir_structure do |dir, remote|
            connection.should_receive(:putbinaryfile).with("#{dir}/README", "#{remote}/README").and_return(true)
            connection.should_receive(:mkdir).with("#{dir}/subdir")
            connection.should_receive(:putbinaryfile).with("#{dir}/subdir/README", "#{remote}/subdir/README").and_return(true)
            ftp.send_directory(dir)
          end
        end

      end
    end
  end
end

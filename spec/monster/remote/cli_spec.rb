module Monster
  module Remote

    describe CLI do

      module ::Kernel
        def rescuing_exit
          yield
          rescue SystemExit
        end
      end

      def executable
        File.join(File.expand_path("../../../../", __FILE__), "bin/monster_remote")
      end

      before(:all) do
        @current_dir = Dir.pwd
        @net_ftp = Monster::Remote::Wrappers::NetFTP
      end

      before do
        @syncer = double("sync contract").as_null_object
        @syncer.stub(:new).and_return(@syncer)
        @out = double("out contract").as_null_object
        @in = double("in contract").as_null_object
        @password = "123"
        @in.stub(:gets).and_return(@password)

        @cli = CLI.new(@syncer, @out, @in)
      end

      it "-v returns the version" do
        rescuing_exit { @cli.run(["-v"]) == Monster::Remote::VERSION }
      end

      it "-p calls #gets on the given 'input'" do
        rescuing_exit do
          @in.should_receive(:gets)
          @cli.run(["-p"])
        end
      end

      context "using the 'sync' interface" do

        before do
          @wrapper = double("fake wrapper").as_null_object
          @dirname = File.basename(@current_dir)
          Monster::Remote::Wrappers::NetFTP = @wrapper
        end

        it "--ftp -p awaits for password even if another flags/options" do
          rescuing_exit do 
            @in.should_receive(:gets)
            @cli.run(["--ftp", "-p"])
          end
        end

        it "--ftp and ::new parameters" do
          @syncer.should_receive(:new).with(@wrapper, @current_dir, @dirname, nil)
          rescuing_exit do
            @cli.run(["--ftp"])
          end
        end

        it "uses NetFTP as default wrapper" do
          @syncer.should_receive(:new).with(@wrapper, @current_dir, @dirname, nil)
          rescuing_exit do
            @cli.run(["-p"])
          end
        end

        it "--verbose turn on the syncer verbosity" do
          out = STDOUT.clone
          STDOUT = double("omg my own stdout")
          @syncer.should_receive(:new).with(@wrapper, @current_dir, @dirname, STDOUT)
          rescuing_exit do
            @cli.run(["--verbose"])
          end
          STDOUT = out
        end

        it "-l allow configure the local dir" do
          local_dir = "opa/lele"
          @syncer.should_receive(:new).with(@wrapper, local_dir, File.basename(local_dir), nil)
          rescuing_exit do
            @cli.run(["-l", local_dir])
          end
        end

        it "-r allow specify the remote dir" do
          remote = "test/omg/gogo"
          @syncer.should_receive(:new).with(@wrapper, @current_dir, remote, nil)
          rescuing_exit do
            @cli.run(["-r", remote])
          end
        end

        it "start sync with default configurations" do
          @syncer.should_receive(:start).with(nil, nil, "localhost", 21)
          rescuing_exit do
            @cli.run
          end
        end

        it "-H allow specify the server host" do
          host = "borba"
          @syncer.should_receive(:start).with(nil, nil, host, 21)
          rescuing_exit do
            @cli.run(["-H", host])
          end
        end

        it "-P allow specify the host port" do
          host = "borba"
          port = "portalhes"
          @syncer.should_receive(:start).with(nil, nil, host, port)
          rescuing_exit do
            @cli.run(["-H", host, "-P", port])
          end
        end

        it "-u specify the user" do
          user = "omg-my-user"
          @syncer.should_receive(:start).with(user, nil, "localhost", 21)
          rescuing_exit do
            @cli.run(["-u", user])
          end
        end

        it "-p specify the password" do
          user = "omg-my-user"
          @syncer.should_receive(:start).with(user, @password, "localhost", 21)
          rescuing_exit do
            @cli.run(["-u", user, "-p"])
          end
        end

      end# sync

      context "executable" do

        it "-v returns the version" do
          `#{executable} -v`.strip.should == Monster::Remote::VERSION
        end# -v

      end# executable

      after(:all) do
        Monster::Remote::Wrappers::NetFTP = @net_ftp
      end

    end# CLI
  end
end

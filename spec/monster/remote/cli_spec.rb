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
        @wrapper = double("fake wrapper").as_null_object

        @cli = CLI.new(@syncer, @out, @in)
      end

      it "-v returns the version" do
        rescuing_exit { @cli.run(["-v"]) == Monster::Remote::VERSION }
      end

      context "-p (wait for passowrd)" do

        it "calls #print with 'password:' on the output" do
          rescuing_exit do
            @out.should_receive(:print).with("password:")
            @cli.run(["-p"])
          end
        end

        it "calls #gets on the input" do
          rescuing_exit do
            @in.should_receive(:gets)
            @cli.run(["-p"])
          end
        end

      end# wait for password

      context "using the 'sync' interface" do

        before do
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

      context "using configs from config file" do
        before(:all) do
          FileUtils.mkdir_p(spec_tmp) unless File.directory?(spec_tmp)
          @file = File.join(spec_tmp, "_config.yml")
          @pwd = Dir.pwd

          Dir.chdir(spec_tmp)
          file_content = "
monster:
  remote:
    host: host
    port: 333
    user: user
    pass: false
    local_dir: local
    remote_dir: remote
"
          File.open(@file, "w") do |f|
            f.write(file_content)
          end
        end

        it "calls #start with configs from file" do
          @syncer.should_receive(:start).with("user", nil, "host", 333)
          rescuing_exit do
            @cli.run
          end
        end

        it "calls ::new with configs from file" do
          Monster::Remote::Wrappers::NetFTP = @wrapper
          @syncer.should_receive(:new).with(@wrapper, "local", "remote", nil)
          rescuing_exit do
            @cli.run
          end
        end

        it "command line options should override configs" do
          @syncer.should_receive(:start).with("omg_my_user", nil, "monster", 333)
          rescuing_exit do
            @cli.run(["-u", "omg_my_user", "-H", "monster"])
          end
        end

        it "should wait for password if configs says so" do
          file_content = "
monster:
  remote:
    host: host
    port: 333
    user: user
    pass: true
    local_dir: local
    remote_dir:
"
          File.open(@file, "w") do |f|
            f.write(file_content)
          end
          @syncer.should_receive(:start).with("user", @password, "host", 333)
          rescuing_exit do
            @cli.run
          end
        end

        after(:all) do
          FileUtils.rm_rf(spec_tmp) if File.directory?(spec_tmp)
          Dir.chdir(@pwd)
        end

      end# _config.yml

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

module Monster
  module Remote

    describe Configuration do
      def minimal_config_file(host="host")
"monster:
  remote:
    host: #{host}
"
      end

      def path_to(file="o_m_g.yml")
        File.join(spec_tmp, file)
      end

      before(:all) do
        FileUtils.mkdir_p(spec_tmp)
        @file_content = minimal_config_file << "
    port: 333
    user: user
    pass: true
    local_dir: local
    remote_dir:
"
      end

      it "ignores the abscence of config file" do
        lambda { Configuration.new }.should_not raise_error
      end

      context "specific file on the constructor, properties" do

        before(:all) do
          @file = "o_m_g.yml"
          File.open(path_to(@file), "w") do |f|
            f.write(@file_content)
          end
          @conf = Configuration.new(path_to(@file))
        end

        it "#host" do
          @conf.host.should == "host"
        end

        it "#port" do
          @conf.port.should == 333
        end

        it "#user" do
          @conf.user.should == "user"
        end

        it "#password_required?" do
          @conf.password_required?.should be_true
        end

        it "#local_dir" do
          @conf.local_dir.should == "local"
        end

        it "#remote_dir" do
          @conf.remote_dir.should be_nil
        end

        after(:all) do
          FileUtils.rm(path_to(@file)) if File.exists?(path_to(@file))
        end

      end# specific file

      context "uses _config.yml as default configuration" do

        before(:all) do
          @pwd = Dir.pwd
          Dir.chdir(spec_tmp)
          @file = "_config.yml"
          File.open(path_to(@file), "w") do |f|
            f.write(minimal_config_file("borba"))
          end
          @conf = Configuration.new
        end

        it "gets configs from _config.yml by default" do
          @conf.host.should == "borba"
        end

        after(:all) do
          FileUtils.rm(@file)
          Dir.chdir(@pwd)
        end

      end# defaults to _config.yml

      context "uses .monster.yml as fallback for _config.yml" do

        before(:all) do
          @pwd = Dir.pwd
          Dir.chdir(spec_tmp)
          @file = ".monster.yml"
          File.open(path_to(@file), "w") do |f|
            f.write(minimal_config_file("lacatumba"))
          end
          @conf = Configuration.new
        end

        it "gets configs from .monster.yml" do
          @conf.host.should == "lacatumba"
        end

        after(:all) do
          FileUtils.rm(@file)
          Dir.chdir(@pwd)
        end

      end

      after(:all) do
        FileUtils.rm_rf(spec_tmp) if File.exists?(spec_tmp)
      end

    end# Configuration

  end# Remote
end# Monpatster

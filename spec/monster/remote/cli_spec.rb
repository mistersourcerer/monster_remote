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

      before :all do
        @cli = CLI.new
      end

      it "-v returns the version" do
        rescuing_exit do
          @cli.run(["-v"]) == Monster::Remote::VERSION
        end
      end

      context "executable" do

        it "-v returns the version" do
          `#{executable} -v`.strip.should == Monster::Remote::VERSION
        end
      end # -v
    end
  end
end

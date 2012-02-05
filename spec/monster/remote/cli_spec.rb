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

      before do
        @out = double("out contract").as_null_object
        @in = double("in contract").as_null_object
        @cli = CLI.new(@out, @in)
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

      context "executable" do

        it "-v returns the version" do
          `#{executable} -v`.strip.should == Monster::Remote::VERSION
        end
      end # -v
    end
  end
end

module Monster
  module Remote

    describe CLI do

      def executable
        File.join(File.expand_path("../../../../", __FILE__), "bin/monster_remote")
      end

      context "monster_remote -v" do

        it "return the version" do
          `#{executable} -v`.should == Monster::Remote::VERSION
        end

      end # -v
    end
  end
end

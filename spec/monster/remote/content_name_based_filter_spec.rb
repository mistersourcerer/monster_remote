module Monster
  module Remote
    module Filters

      describe ContentNameBasedFilter do
        def create_fake_dirs
          @all_entries.each do |dir|
            FileUtils.mkdir_p(File.join(@root_dir, dir))
          end
        end

        before(:all) do
          FakeFS.activate!
          @root_dir = "/jajaja"
          @allowed = ["I_CAN_BE_FILE", "ME_CAN"]
          @forbidden = [".", "..", ".mafagafanho", "borba"]
          @all_entries = @allowed + @forbidden
          create_fake_dirs
        end

        before do
          @filter = subject
        end

        describe "#reject, configuring forbbiden names" do

          it "accept string as parameter" do
            @filter.reject "."
            @filter.reject ".."
            @filter.filter(["a", ".", ".."]).should == ["a"]
          end

          it "or any Enumerable" do
            rejecting = ["a", "bb", "ccc"]
            @filter.reject rejecting
            @filter.filter(rejecting + ["opalhes"]).should == ["opalhes"]
          end

          it "accept a block which make the rejection logic" do
            @filter.reject lambda{ |entries| entries.reject{|entry| entry != "borba"} }
            @filter.filter(["a", "b", "borba"]).should == ["borba"]
          end
        end # #reject

        it "accepts a dir name and return only allowed entries" do
          @filter.reject @forbidden
          @filter.filter(@root_dir).should == @allowed
        end

        after(:all) do
          FakeFS.deactivate!
        end
      end
    end
  end
end

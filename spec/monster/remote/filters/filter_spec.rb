module Monster
  module Remote
    module Filters

      describe Filter do

        it "accept a block with rejection logic, the list is passed as argument" do
          filter = Filter.new
          filter.reject lambda{ |entries| entries.reject{|entry| entry != "borba"} }
          filter.filter(["a", "b", "borba"]).should == ["borba"]
        end
      end # describe Filter
    end
  end
end


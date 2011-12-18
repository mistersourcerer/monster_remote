module Monster
  module Remote

    class ContentNameBasedFilter

      def reject(reject_logic)
        @rejecting ||= []
        rejections = []
        if reject_logic.respond_to? :call
          rejections << reject_logic
        else
          rejections = become_block(reject_logic)
        end
        @rejecting += rejections
      end

      def become_block(reject)
        rejection_blocks = []
        reject = [reject] unless reject.respond_to? :each
        reject.each do |to_reject|
          rejection_blocks << lambda {
            |entries| entries.reject { |entry| to_reject == entry }
          }
        end
        rejection_blocks
      end

      def filter(directory)
        allowed = become_array(directory)
        @rejecting.each do |logic|
          allowed = logic.call(allowed)
        end
        allowed
      end

      def become_array(to_reject)
        to_reject_array = []
        if(to_reject.respond_to?(:each))
          to_reject.each {|entry| to_reject_array << entry}
        else
          to_reject_array = Dir.entries(to_reject)
        end
        to_reject_array
      end
    end # ContentNameBasedFilter
  end
end

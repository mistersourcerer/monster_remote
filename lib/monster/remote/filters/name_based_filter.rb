require 'monster/remote/filters/filter'

module Monster
  module Remote

    class NameBasedFilter < Filter

      def reject(reject_logic)
        if reject_logic.respond_to? :call
          super(reject_logic)
        else
          become_block(reject_logic).each do |rejection|
            super(rejection)
          end
        end
        self
      end

      def filter(directory)
        dir_structure = become_array(directory)
        super(dir_structure)
      end

      private

      def become_block(reject)
        rejection_blocks = []
        reject = [reject] unless reject.respond_to? :each
        reject.each do |to_reject|
          rejection_blocks << lambda { |entries|
            entries.reject { |entry| to_reject == entry }
          }
        end
        rejection_blocks
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

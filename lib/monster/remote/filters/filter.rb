module Monster
  module Remote

    class Filter

      def reject(reject_logic)
        @rejecting ||= []
        @rejecting << reject_logic
        self
      end

      def filter(entries)
        return [] if entries.nil?
        allowed = entries
        @rejecting.each do |logic|
          allowed = logic.call(allowed)
        end
        allowed
      end

    end # Filter
  end
end


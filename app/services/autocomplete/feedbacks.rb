module Autocomplete
  class Feedbacks
    def initialize search_query
      @search_query = search_query
    end

    def call
      search_results.map do |feedback|
        # Show little data on purpose for privacy reasons.
        {
          id: feedback.id,
          date: (feedback.created_at.strftime '%Y-%m-%d %H:%M'),
          status: (feedback.open? ? "open" : "closed")
        }
      end
    end

    private
      attr_reader :search_query

      def search_results
        exact_id_match || Feedback.where("id LIKE ?", "%#{search_query}%").order(id: :desc)
      end

      def exact_id_match
        return unless search_query =~ /^\d+ ?$/

        match = Feedback.find_by id: search_query
        [match] if match
      end
  end
end

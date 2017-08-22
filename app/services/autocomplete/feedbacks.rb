module Autocomplete
  class Feedbacks
    def initialize search_query
      @search_query = search_query
    end

    def call
      # See if we have an exact ID match.
      search_results = if search_query =~ /^\d+ ?$/
                         id_matches_q = Feedback.find_by id: search_query
                         [id_matches_q] if id_matches_q
                       end

      search_results ||= Feedback.where("id LIKE ?", "%#{search_query}%").order(id: :desc)

      search_results.map do |feedback|
        # Show less data on purpose for privacy reasons.
        { id: feedback.id,
          date: (feedback.created_at.strftime '%Y-%m-%d %H:%M'),
          status: (feedback.open? ? "open" : "closed")
        }
      end
    end

    private
      attr_reader :search_query
  end
end

module Autocomplete
  class Journals
    def initialize search_query = ''
      @search_query = search_query
    end

    def call
      Journal.select('journals.name, COUNT(*)')
        .joins('LEFT OUTER JOIN `references` ON references.journal_id = journals.id')
        .where('journals.name LIKE ?', search_expression)
        .group('journals.id')
        .order('COUNT(*) DESC')
        .map(&:name)
    end

    private
      attr_reader :search_query

      def search_expression
        search_query.split('').join('%') + '%'
      end
  end
end

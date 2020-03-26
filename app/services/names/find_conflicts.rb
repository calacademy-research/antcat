# frozen_string_literal: true

module Names
  class FindConflicts
    include Service

    NUM_ITEMS = 30

    SINGLE_WORD_NAMES_ONLY = 'single_word_names'
    NO_SINGLE_WORD_NAMES = 'no_single_word_names'

    def initialize search_query, number_of_words, except_name_id
      @search_query = search_query
      @number_of_words = number_of_words.presence
      @except_name_id = except_name_id.presence
    end

    def call
      names = Name.select('names.*, taxa.id AS taxon_id, protonyms.id AS protonym_id').
        left_outer_joins(:taxa, :protonyms).
        where("taxa.id IS NOT NULL OR protonyms.id IS NOT NULL")

      case number_of_words
      when SINGLE_WORD_NAMES_ONLY
        names = names.single_word_names
      when NO_SINGLE_WORD_NAMES
        names = names.no_single_word_names
      end

      if except_name_id
        names = names.where.not(id: except_name_id)
      end

      names.where("names.name LIKE ?", wildcard_search_query).limit(NUM_ITEMS)
    end

    private

      attr_reader :search_query, :number_of_words, :except_name_id

      def wildcard_search_query
        search_query.split(' ').join('%') + '%'
      end
  end
end

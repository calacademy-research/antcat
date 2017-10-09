module References
  class MatchReferences
    include Service

    def initialize target, min_similarity: 0.01
      @target = target
      @min_similarity = min_similarity
    end

    def call
      match
    end

    private
      attr_reader :target, :min_similarity

      def match
        candidates_for(target).reduce([]) do |matches, candidate|
          if possible_match? target, candidate
            similarity = References::ReferenceSimilarity[target, candidate]
            matches << { target: target, match: candidate, similarity: similarity } if similarity >= min_similarity
          end
          matches
        end
      end

      def possible_match? target, candidate
        target.id != candidate.id
      end

      # TODO see if we can avoid using instance variables.
      def candidates_for target
        if target.principal_author_last_name_cache != @target_author
          @target_author = target.principal_author_last_name_cache
          @candidates = read_references @target_author
        end
        @candidates || []
      end

      def read_references target
        ::Reference.with_principal_author_last_name target
      end
  end
end

# TODO: Use Solr or Elasticsearch instead of this class.

module References
  class FindDuplicates
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
        candidates.each_with_object([]) do |candidate, matches|
          similarity = reference_similarity candidate
          matches << { target: target, match: candidate, similarity: similarity } if similarity >= min_similarity
        end
      end

      def candidates
        return [] unless target.principal_author_last_name

        target_author = target.principal_author_last_name
        Reference.where.not(id: target.id).joins(:author_names).where(reference_author_names: { position: 1 }).
          where("author_names.name LIKE ?", "#{target_author}%")
      end

      def reference_similarity candidate
        References::ReferenceSimilarity[target, candidate]
      end
  end
end

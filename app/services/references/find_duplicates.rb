# frozen_string_literal: true

# TODO: Use Solr or Elasticsearch instead of this class.

module References
  class FindDuplicates
    include Service

    attr_private_initialize :target, [min_similarity: 0.01]

    def call
      match
    end

    private

      def match
        candidates.each_with_object([]) do |candidate, matches|
          similarity = reference_similarity candidate
          matches << { target: target, match: candidate, similarity: similarity } if similarity >= min_similarity
        end
      end

      def candidates
        return [] unless (target_author = target.author_names.first&.last_name)

        Reference.where.not(id: target.id).joins(:author_names).where(reference_author_names: { position: 1 }).
          where("author_names.name LIKE ?", "#{target_author}%")
      end

      def reference_similarity candidate
        References::ReferenceSimilarity[target, candidate]
      end
  end
end

module Authors
  class DescribedTaxa
    include Service

    def initialize author
      @author = author
    end

    def call
      taxa_described_by_author
    end

    private

      attr_reader :author

      delegate :id, to: :author

      def taxa_described_by_author
        Taxon.joins(<<-SQL.squish).where("a.id = #{id}")
          JOIN protonyms ON protonym_id = protonyms.id
          JOIN citations ON authorship_id = citations.id
          JOIN `references` ON reference_id = `references`.id
          JOIN reference_author_names ran ON ran.reference_id = references.id
          JOIN author_names an ON ran.author_name_id = an.id
          JOIN authors a ON an.author_id = a.id
        SQL
      end
  end
end

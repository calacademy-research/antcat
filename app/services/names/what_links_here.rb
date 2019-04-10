module Names
  class WhatLinksHere
    include Service

    def initialize name
      @name = name
    end

    def call
      references_to_taxon_name.concat(references_to_protonym_name)
    end

    private

      attr_reader :name

      delegate :taxa, :protonyms, to: :name

      def references_to_taxon_name
        taxa.pluck(:id).map do |taxon_id|
          table_ref 'taxa', :name_id, taxon_id
        end
      end

      def references_to_protonym_name
        protonyms.pluck(:id).map do |protonym_id|
          table_ref 'protonyms', :name_id, protonym_id
        end
      end

      def table_ref table, field, id
        { table: table, field: field, id: id }
      end
  end
end

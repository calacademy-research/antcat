module Names
  class WhatLinksHere
    include Service

    def initialize name
      @name = name
    end

    def call
      references_in_fields.concat(references_in_taxt)
    end

    private

      attr_reader :name

      delegate :id, to: :name

      def references_in_fields
        references_to_taxon_name.
          concat(references_to_taxon_type_name).
          concat(references_to_protonym_name)
      end

      def references_to_taxon_name
        Taxon.where(name: name).pluck(:id).map do |taxon_id|
          table_ref 'taxa', :name_id, taxon_id
        end
      end

      def references_to_taxon_type_name
        Taxon.where(type_name: name).pluck(:id).map do |taxon_id|
          table_ref 'taxa', :type_name_id, taxon_id
        end
      end

      def references_to_protonym_name
        Protonym.where(name: name).pluck(:id).map do |protonym_id|
          table_ref 'protonyms', :name_id, protonym_id
        end
      end

      def references_in_taxt
        references = []
        Taxt.models_with_taxts.each_field do |field, model|
          model.where("#{field} LIKE '%{nam #{name.id}}%'").pluck(:id).each do |id|
            references << table_ref(model.table_name, field.to_sym, id)
          end
        end
        references
      end

      def table_ref table, field, id
        { table: table, field: field, id: id }
      end
  end
end

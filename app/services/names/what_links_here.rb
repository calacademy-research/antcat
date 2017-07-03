module Names
  class WhatLinksHere
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
        references_to_taxon_name
          .concat(references_to_taxon_type_name)
          .concat(references_to_protonym_name)
      end

      def references_to_taxon_name
        Taxon.where(name: name).map do |taxon|
          table_ref 'taxa', :name_id, taxon.id
        end
      end

      def references_to_taxon_type_name
        Taxon.where(type_name: name).map do |taxon|
          table_ref 'taxa', :type_name_id, taxon.id
        end
      end

      def references_to_protonym_name
        Protonym.where(name: name).map do |protonym|
          table_ref 'protonyms', :name_id, protonym.id
        end
      end

      def references_in_taxt
        references = []
        Taxt::TAXT_FIELDS.each do |klass, fields|
          table = klass.arel_table
          fields.each do |field|
            klass.where(table[field].matches("%{nam #{id}}%")).each do |record|
              next unless record[field]
              if record[field] =~ /{nam #{id}}/
                references << table_ref(klass.table_name, field, record.id)
              end
            end
          end
        end
        references
      end

      def table_ref table, field, id
        { table: table, field: field, id: id }
      end
  end
end

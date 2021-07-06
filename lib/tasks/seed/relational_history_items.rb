# frozen_string_literal: true

module Seed
  class RelationalHistoryItems
    def self.call
      new.call
    end

    def call
      tatusia.history_items.destroy_all

      tatusia.history_items.create! type: History::Definitions::SENIOR_SYNONYM_OF,
        object_protonym: kapasi,
        reference: ref_2016, pages: '1'
      tatusia.history_items.create! type: History::Definitions::SENIOR_SYNONYM_OF,
        object_protonym: kapasi,
        force_author_citation: true,
        reference: ref_2012, pages: '69'

      tatusia.history_items.create! type: History::Definitions::JUNIOR_SYNONYM_OF,
        object_protonym: fusca, reference: ref_2020, pages: '4'

      tatusia.history_items.create! type: History::Definitions::TAXT,
        taxt: 'Old-style taxt'
      tatusia.history_items.create! type: History::Definitions::TAXT,
        taxt: 'Old-style taxt 2'

      tatusia.history_items.create! type: History::Definitions::FORM_DESCRIPTIONS,
        text_value: 'w.q.',
        reference: ref_1968, pages: '2'

      tatusia.history_items.create! type: History::Definitions::TYPE_SPECIMEN_DESIGNATION,
        subtype: History::Definitions::LECTOTYPE_DESIGNATION,
        reference: ref_2016, pages: '555'

      tatusia.history_items.create! type: History::Definitions::TYPE_SPECIMEN_DESIGNATION,
        subtype: History::Definitions::NEOTYPE_DESIGNATION,
        reference: ref_2016, pages: '559'

      tatusia.history_items.create! type: History::Definitions::COMBINATION_IN,
        object_taxon: lasius_taxon, reference: ref_2020, pages: '7'

      tatusia.history_items.create! type: History::Definitions::SUBSPECIES_OF,
        object_protonym: fusca, reference: ref_2020, pages: '12'

      tatusia.history_items.create! type: History::Definitions::STATUS_AS_SPECIES,
        reference: ref_2020, pages: '15'

      tatusia.history_items.create! type: History::Definitions::HOMONYM_REPLACED_BY,
        object_protonym: fusca, reference: ref_2020, pages: '12'

      tatusia.history_items.create! type: History::Definitions::HOMONYM_REPLACED_BY,
        object_protonym: fusca

      tatusia.history_items.create! type: History::Definitions::REPLACEMENT_NAME_FOR,
        object_protonym: lasius
    end

    private

      def ref_1809
        @_ref_1809 ||= Reference.find(126798)
      end

      def ref_1968
        @_ref_1968 ||= Reference.find(123253)
      end

      def ref_2012
        @_ref_2012 ||= Reference.find(142238)
      end

      def ref_2016
        @_ref_2016 ||= Reference.find(142921)
      end

      def ref_2020
        @_ref_2020 ||= Reference.find(143559)
      end

      def tatusia
        @_tatusia ||= Taxon.find_by!(name_cache: 'Tatuidris tatusia').protonym
      end

      def kapasi
        @_kapasi ||= Taxon.find_by!(name_cache: 'Tatuidris kapasi').protonym
      end

      def fusca
        fusca_taxon.protonym
      end

      def fusca_taxon
        @_fusca_taxon ||= Taxon.find_by!(name_cache: 'Formica fusca')
      end

      def lasius
        lasius_taxon.protonym
      end

      def lasius_taxon
        @_lasius_taxon ||= Taxon.find_by!(name_cache: 'Lasius')
      end
  end
end

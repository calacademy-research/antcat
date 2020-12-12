# frozen_string_literal: true

module Seed
  class HybridHistoryItems
    def self.call
      new.call
    end

    def initialize
      HistoryItem::TYPES.each do |type|
        Seed::HybridHistoryItems.const_set(type.underscore.upcase, type) # Super lazy...
      end
    end

    def call
      tatusia.history_items.destroy_all

      tatusia.history_items.create! type: SENIOR_SYNONYM_OF,
        object_protonym: kapasi,
        reference: ref_2016, pages: '1'
      tatusia.history_items.create! type: SENIOR_SYNONYM_OF,
        object_protonym: kapasi,
        reference: ref_2012, pages: '69'

      tatusia.history_items.create! type: JUNIOR_SYNONYM_OF,
        object_protonym: fusca, reference: ref_2020, pages: '4'

      tatusia.history_items.create! type: TAXT, taxt: 'Old-style taxt'
      tatusia.history_items.create! type: TAXT, taxt: 'Old-style taxt 2'

      tatusia.history_items.create! type: FORM_DESCRIPTIONS,
        text_value: 'w.q.',
        reference: ref_1968, pages: '2'

      tatusia.history_items.create! type: TYPE_SPECIMEN_DESIGNATION,
        subtype: HistoryItem::LECTOTYPE_DESIGNATION,
        reference: ref_2016, pages: '555'

      tatusia.history_items.create! type: TYPE_SPECIMEN_DESIGNATION,
        subtype: HistoryItem::NEOTYPE_DESIGNATION,
        reference: ref_2016, pages: '559'

      tatusia.history_items.create! type: COMBINATION_IN,
        object_protonym: lasius, reference: ref_2020, pages: '7'

      tatusia.history_items.create! type: SUBSPECIES_OF,
        object_protonym: fusca, reference: ref_2020, pages: '12'

      tatusia.history_items.create! type: STATUS_AS_SPECIES,
        reference: ref_2020, pages: '15'
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
        @_fusca ||= Taxon.find_by!(name_cache: 'Formica fusca').protonym
      end

      def lasius
        @_lasius ||= Taxon.find_by!(name_cache: 'Lasius').protonym
      end
  end
end
